# Newdok 아키텍처 리뷰 및 Article Highlight 설계

대상: Tuist 기반 멀티모듈(TMA) iOS 앱. 범위는 (1) 에러 처리, (2) 모듈화, (3) Article Highlight 리팩토링 설계.

---

## 1. 에러 처리

### 검토 항목
- 레이어별 에러 타입의 정의·변환·전파가 의존성 규칙을 따르는가
- 서버 에러 응답 body의 메시지가 사용자까지 전달되는가
- DesignSystem 시스템 에러 팝업과 에러 파이프라인의 연결 구조
- 팝업 노출 메커니즘 end-to-end
- 파이프라인의 레이어 위반 여부

### 변환 경로
```
MoyaError → NetworkError (NetworkKit) → AppError (Shared) → ViewModel.currentError → UI
```
- `NetworkKit`은 `AppError`를 import하지 않음. `Shared`는 `NetworkKit`을 import하지 않음.
- `NetworkError → AppError` 매핑은 App의 `NetworkErrorAppMapper`가 수행하며 `AppErrorMapperRegistry`에 등록(`NewdokApp.init`). 두 모듈 간 직접 의존 없이 컴포지션 루트에서 연결.

### 발견
- **서버 메시지 유실**: `ErrorMapper`(`ErrorMapper.swift:13-29`)가 응답 body를 `NetworkError.serverError(_, message)`에 보존하나, `NetworkErrorAppMapper`(`NetworkErrorAppMapper.swift:14`)가 매핑 시 `message`를 폐기. 4xx(401 제외) → `.silent`, 5xx → `.serverError`로 고정.
- **dead case**: `AppError.serverMessage(String)`(`AppError.swift:13`)은 생성처가 없음(`grep` 결과 정의부 1건). 메시지 전달용으로 존재하나 미연결.
- **레이어 누수**: `ServerErrorPopupModifier`(`ServerErrorPopupModifier.swift`)가 `import Shared` 후 `error == .serverError`로 분기. DesignSystem(leaf 모듈)이 앱 도메인 에러 `AppError`에 의존. DesignSystem에서 `AppError` 참조 파일은 이 1건.
  - 대조: `NetworkErrorView` 팝업은 `OverlayRootView`가 `NetworkStatusManager.isConnected`(Bool)로 트리거하며 `AppError`를 모름.

### 팝업 노출 메커니즘
1. `handleError`(`ErrorHandling.swift:16`) → 레지스트리 매핑 → `currentError = .serverError`
2. `@Observable` 갱신 → 뷰 재평가
3. `.serverErrorPopup(error:)` 모디파이어가 `isPresented = (error == .serverError)`로 변환
4. `PopupView`가 `ServerErrorPopupView` 렌더
5. `onRetry` → `error = nil` → 닫힘 + 재요청
- 12개 피처 뷰가 동일 모디파이어를 각자 부착. 트리거·문구 동일, `onRetry`만 상이.

### 개선안 (누수 해소)
- DesignSystem 모디파이어 파라미터를 `Binding<AppError?>` → `Binding<Bool>`로 변경, `import Shared` 제거.
- `== .serverError` 판정을 `AppError`를 의존하는 Feature 호출부로 이동.
- 결과: DesignSystem → Shared 의존 제거, NetworkError 팝업의 Bool 트리거 방식과 통일.

---

## 2. 모듈화

### 의존성 그래프
```
App → Features(TMA × 9) → Core → External
```
| 모듈 | 의존 |
|---|---|
| Shared, FoundationKit, DatabaseKit | (leaf) |
| NetworkKit | Shared, Moya |
| DesignSystem | Shared, Kingfisher, PopupView |

### Feature 내부 (TMA)
| 타겟 | 의존 | 책임 |
|---|---|---|
| `{F}Interface` | (custom) | 노출 프로토콜 |
| `{F}Domain` | (custom, 일부 FoundationKit) | UseCase, Entity, Repository 프로토콜, DomainError |
| `{F}Data` | `{F}Domain`, NetworkKit (+DatabaseKit) | Repository 구현, DTO, TargetType |
| `{F}` | `{F}Interface`, `{F}Domain`, DesignSystem, Shared (+DI용 `{F}Data`) | View, ViewModel |

### 검증 결과
- Sources 타겟에서 Data/NetworkKit/DatabaseKit을 import하는 파일은 `*DIContainer`/`*Builder` 조립 파일에 한정. View/ViewModel 파일은 import 0건.
- `import SwiftData`/`@Query`/`@Model`: Sources 전체 0건.
- `BrandDetailViewModel`은 `DetailDomain`·`Shared`만 import, 생성자로 `DetailBrandRepository` 프로토콜 주입.
- 컴포지션 루트 `AppContainer`가 `*Buildable` 프로토콜로 각 Builder 조립, `deps.networkProvider` 주입.
- 순환 의존 없음.

### 잔여 항목
- 피처 DI 조립(`*Builder`/`*DIContainer`)이 View/ViewModel과 동일 `Sources` 타겟에 위치. Presentation 타겟이 빌드 그래프상 Data/NetworkKit을 링크. 조립을 별도 타겟으로 분리하면 순수 Presentation 타겟은 Domain만 링크. 선택적 개선.

---

## 3. Article Highlight 리팩토링 설계

대상: `Modules/Features/Detail/Sources/Article/*`, 특히 `ArticleHighlightJS.swift`(757줄).

### 현재 부채
| # | 내용 | 위치 |
|---|---|---|
| 1 | JS 757줄이 Swift 문자열 리터럴, 이스케이프 4중첩 | `ArticleHighlightJS.swift` (`swiftlint:disable file_length`) |
| 2 | messageHandler 5개 분산 + `console.log` 프로덕션 잔류 | `ArticleWebView.swift:50-54`, `:152` |
| 3 | 색/밑줄 stringly-typed, JS·VM·Repo 3중 중복 | `:303`, `:467`, `saveHighlight(type: String)` |
| 4 | 위치를 raw 텍스트로 저장·재검색, 중복 텍스트 시 첫 매칭 채택 | `ArticleDetailViewModel.swift:136,151` |

ViewModel·Domain·Data 레이어 변경 없음.

### RN 전환 평가
- `react-native-webview`의 내부 구현은 WKWebView. 임의 HTML 본문 하이라이팅은 RN 네이티브 컴포넌트로 대체 불가, 주입 JS 필요.
- 부채 1·4는 런타임과 무관(JS 작성 방식·위치 식별 모델 문제)하여 RN이 해결하지 못함.
- 단일 패러다임(Swift/TMA)에 RN 런타임 추가 시 Metro/Hermes·브릿지·앱 용량 비용 발생.
- 결정: RN 선제 도입 기각.

### 목표 구조 (Ports & Adapters)
```
ArticleDetailViewModel → HighlightRenderable → WebViewHighlightRenderer
                         send(Command)/events    ⇅ Codable 봉투
                                                 highlight-engine.bundle.js (TS, window.HighlightEngine)

DetailDomain: HighlightLocator, HighlightStyle, HighlightCommand, HighlightEvent
```

### 네이밍
| 역할 | 이름 | 종류 | 근거 |
|---|---|---|---|
| 포트 | `HighlightRenderable` | protocol | `-able` 컨벤션, 기존 `*Buildable` |
| 구현체 | `WebViewHighlightRenderer` | class | WKWebView 격리 |
| 명령 | `HighlightCommand` | enum | Swift→JS |
| 이벤트 | `HighlightEvent` | enum | JS→Swift |
| 위치 기술자 | `HighlightLocator` | struct | `Selector`(Swift `#selector`/CSS)·`Anchor`(DOM `<a>`)·`Range` 충돌 회피 |
| 위치 전략 | `LocatorStrategy` | enum | W3C selector명 매핑 |
| 색/밑줄 | `HighlightStyle` | enum | 기존 `highlightType` rename |

### 시그니처
```swift
protocol HighlightRenderable {
    func send(_ command: HighlightCommand)
    var events: AsyncStream<HighlightEvent> { get }
}

enum HighlightCommand {
    case render(article: ArticleContent, highlights: [Highlight])
    case apply(Highlight)
    case scrollTo(HighlightLocator)
    case remove(HighlightLocator)
    case setFontSize(CGFloat)
}

enum HighlightEvent {
    case selected(text: String, locator: HighlightLocator)
    case applied(locator: HighlightLocator, style: HighlightStyle)
    case styleChanged(locator: HighlightLocator, to: HighlightStyle)
    case deleted(locator: HighlightLocator)
}

struct HighlightLocator { let strategies: [LocatorStrategy] }
enum LocatorStrategy {
    case textPosition(start: Int, end: Int)
    case textQuote(prefix: String, exact: String, suffix: String)
}
```
명령·이벤트는 `{ type, payload }` Codable 봉투로 직렬화. 단일 인코딩/디코딩 경로.

### 패턴 결정
| 패턴 | 결정 | 근거 |
|---|---|---|
| Ports & Adapters | 채택 | WebView를 교체 가능한 디테일로 격리 |
| Command (`send(Command)`) | 채택 | 포트 2메서드, 양방향 대칭 |
| W3C selector 체인 (Strategy) | 채택 | 중복 텍스트 식별, 라이브러리 1:1 매핑 |
| 팔레트 Fat-JS | 채택 | 스크롤 좌표 동기화 회피. 테스트성은 Thin과 동등 |
| TCA/Redux | 기각 | 앱 전체 `@Observable` MVVM과 불일치 |
| RPC 코드젠 / Event Sourcing | 기각 | 범위 대비 과도 |

팔레트 Fat/Thin 분석: 테스트 난점은 선택 이벤트가 DOM에서 발생하는 데서 기인하며 팔레트 구현 위치와 무관. Thin-JS의 유효 이점은 디자인 일관성에 한정되고 스크롤 좌표 동기화 비용과 상쇄.

### 테스트 전략
1층 (WebView 불필요)
- VM 로직: `DetailTesting` mock + XCTest
- Command/Event 직렬화: Codable round-trip
- 위치 해석·중복·폴백: TS 번들 jsdom/vitest
- 팔레트 빌더: TS jsdom

2층 (WKWebView 호스팅, XCUITest 아님)
- 유닛 타겟에서 `WKWebView` 생성, `HighlightEngine` API를 `evaluateJavaScript`로 구동, messageHandler로 결과 회수, `async` 단위테스트로 검증

3층 (XCUITest)
- 선택→팔레트→탭→표시 풀 제스처 happy path 1~2개

### 마이그레이션 단계
| 단계 | 내용 | 위험 | 동작 변화 |
|---|---|---|---|
| 0 | `HighlightStyle` enum 도입 | 낮음 | 없음 |
| 1 | JS를 `.js` 리소스로 추출 | 낮음 | 없음 |
| 2 | 단일 `highlightEvent` 버스 + `HighlightCommand`/`HighlightEvent` | 중간 | 없음 |
| 3 | `HighlightRenderable` 포트 도입 | 중간 | 없음 |
| 4 | JS → TS 프로젝트(`Detail/HighlightEngine/`) + 유닛테스트 | 중간 | 없음 |
| 5 | `HighlightLocator` + 저장 데이터 마이그레이션 | 높음 | 위치 식별 견고성 |
