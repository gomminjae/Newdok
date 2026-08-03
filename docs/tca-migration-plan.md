# Newdok 점진적 TCA 전환 계획

> Status: draft
> 작성일: 2026-08-03
> 범위: Presentation 상태 관리와 App Navigation의 점진적 전환

## 1. 결정 요약

- 기존 Domain, Data, Repository, UseCase 계층은 유지한다.
- TCA는 Feature의 Presentation 계층부터 점진적으로 적용한다.
- 첫 파일럿은 `Search`로 한다.
- Search는 현재 UX를 유지하며 입력 기반 디바운스 검색을 추가하지 않는다.
- 사용자 입력은 `ViewAction`, 비동기 결과는 `ResponseAction`, 상위 화면에 전달할 이벤트는 `DelegateAction`으로 구분한다.
- 기존 `AppCoordinator`와 `Router`는 Feature 파일럿 기간에 유지하고, 패턴 검증 후 탭별로 전환한다.
- 한 PR에서 패키지 도입, Feature 변환, 전체 Navigation 변환을 동시에 수행하지 않는다.
- 최소 2~3개 Feature에서 반복이 확인되기 전에는 공통 `LoadState`, 공통 Reducer 또는 범용 Store 추상화를 만들지 않는다.

## 2. 배경

현재 앱은 SwiftUI와 `@Observable` ViewModel을 사용한다. Domain/Data 계층과 Feature 모듈 경계는 비교적 명확하지만, Presentation 계층에는 다음 문제가 남아 있다.

- View가 ViewModel 상태를 직접 변경한다.
- View가 비동기 `Task`를 직접 생성한다.
- 로딩, 데이터, 에러가 서로 독립된 프로퍼티로 표현돼 모순 상태가 가능하다.
- 요청 취소와 늦은 응답 방지 정책이 Feature마다 다르다.
- 화면 이동이 callback과 `AppCoordinator`에 분산되어 Feature 이벤트 흐름에서 제외된다.
- `ErrorHandling`이 참조 타입의 `currentError`를 직접 변경하므로 값 타입 Reducer와 맞지 않는다.

TCA 전환의 목적은 ViewModel 이름을 Reducer로 바꾸는 것이 아니라, 상태 전이와 Effect 실행 경계를 명시하고 테스트 가능한 단방향 흐름을 만드는 것이다.

## 3. 목표

- View의 모든 상태 변경을 Action으로 표현한다.
- Reducer만 Feature State를 변경한다.
- 네트워크, 저장소, SDK, WebView 연동을 Effect 의존성으로 격리한다.
- 비동기 결과가 Response Action을 통해서만 State에 반영되게 한다.
- 요청 취소와 stale response 방지 정책을 테스트로 보장한다.
- Feature 외부 화면 이동을 Delegate Action으로 표현한다.
- 기존 모듈 경계와 UseCase를 유지하며 화면별로 독립적으로 롤백할 수 있게 한다.
- 최종적으로 ViewModel, callback 기반 Navigation, MVVM 전용 에러 처리 코드를 제거한다.

## 4. 비목표

- TCA 도입과 동시에 NetworkKit 또는 Moya를 교체하지 않는다.
- Domain/Data 계층을 TCA Dependency 구조로 전면 재작성하지 않는다.
- 모든 Feature를 하나의 PR 또는 브랜치에서 한 번에 전환하지 않는다.
- Search에 자동 검색이나 디바운스 UX를 추가하지 않는다.
- 첫 Feature부터 범용 Architecture 프레임워크를 과도하게 설계하지 않는다.
- TCA 전환을 이유로 기존 화면 디자인이나 사용자 흐름을 변경하지 않는다.

## 5. 목표 아키텍처

```text
SwiftUI View
    │ store.send(ViewAction)
    ▼
Feature Reducer ───────────────▶ State
    │ Effect
    ▼
Feature Client Adapter
    ▼
기존 UseCase → Repository → Data/NetworkKit
    │
    └──────── ResponseAction ──▶ Feature Reducer

Feature DelegateAction
    ▼
상위 Tab/App Reducer
    ▼
Navigation State
```

### 계층별 책임

#### View

- Store의 State를 읽어 UI를 렌더링한다.
- 사용자 입력과 lifecycle 이벤트를 Action으로 보낸다.
- 네트워크 UseCase를 호출하거나 비즈니스 `Task`를 만들지 않는다.
- UI에만 필요한 일회성 애니메이션 값은 로컬 `@State`로 둘 수 있다.

#### Feature Reducer

- Action에 따른 유일한 State 변경 지점이다.
- Effect 시작, 취소, 재시도 정책을 결정한다.
- 하위 Feature를 조합하고 Delegate Action을 발생시킨다.

#### Client Adapter

- 기존 UseCase를 TCA Dependency에서 사용할 수 있는 `Sendable` closure로 변환한다.
- Repository와 네트워크 구현을 Reducer에 노출하지 않는다.
- Preview와 Test에서 대체 가능한 인터페이스를 제공한다.

#### App/Tab Reducer

- Feature의 Delegate Action을 처리한다.
- 탭 선택, push/pop, modal과 인증 플로우를 Navigation State로 관리한다.
- 하위 Feature가 구체적인 App Route를 알지 못하게 한다.

## 6. Action 규칙

Feature의 최상위 Action은 출처와 경계에 따라 구분한다.

```swift
enum Action: Equatable {
    case view(ViewAction)
    case response(ResponseAction)
    case delegate(DelegateAction)
}
```

### ViewAction

사용자나 View lifecycle에서 실제로 발생한 사건을 이름으로 표현한다.

```swift
enum ViewAction: Equatable {
    case task
    case queryChanged(String)
    case submitButtonTapped
    case clearButtonTapped
    case resultTapped(id: String)
    case retryButtonTapped
    case disappeared
}
```

- `search`, `clearResults`, `navigateToBrand`처럼 처리 결과를 명령하는 이름을 피한다.
- `submitButtonTapped`, `clearButtonTapped`, `resultTapped`처럼 발생 원인을 기록한다.
- 입력 필드가 적은 화면은 `BindingAction`보다 명시적 변경 Action을 우선한다.

### ResponseAction

Effect만 만들 수 있는 내부 결과다.

```swift
enum ResponseAction: Equatable {
    case searchFinished(
        requestID: UUID,
        query: String,
        Result<[SearchedNewsletter], AppError>
    )
}
```

- View가 직접 Response Action을 보내지 못하도록 접근 수준을 제한한다.
- 취소 가능한 요청은 request ID 또는 TCA cancellation ID를 사용한다.
- 취소된 요청의 기반 네트워크 작업이 끝나더라도 결과가 최신 State를 덮지 못하게 한다.

### DelegateAction

Feature가 직접 처리할 수 없는 상위 이벤트다.

```swift
enum DelegateAction: Equatable {
    case closeRequested
    case brandSelected(id: String)
    case feedbackRequested
}
```

- 하위 Feature는 `HomeRoute`, `ExploreRoute` 등 구체적인 App Route를 알지 않는다.
- 최종 구조에서는 상위 Tab/App Reducer가 Delegate Action을 받아 Navigation State를 변경한다.
- App Navigation 전환 전까지는 기존 callback을 호환 어댑터로 유지하되, 이를 완전한 TCA 전환으로 간주하지 않는다.

## 7. State 규칙

- Reducer가 소유하는 State는 값 타입으로 만든다.
- 테스트에 필요한 State와 Action은 가능한 경우 `Equatable`을 채택한다.
- Effect 경계를 지나는 Domain 값은 가능한 경우 `Sendable`을 채택한다.
- 서로 배타적인 로딩, 성공, 실패 상태를 독립 Bool과 Optional 조합으로 표현하지 않는다.
- 서버 팝업과 inline 에러의 표시 정책은 Reducer에서 결정한다.
- SDK 객체, Repository, WKWebView, renderer 인스턴스를 State에 저장하지 않는다.

Feature별 상태가 2~3개 화면에서 실제로 동일한 형태로 반복된 후 다음 공통 타입 추출을 검토한다.

```swift
enum LoadState<Value: Equatable>: Equatable {
    case idle
    case loading
    case loaded(Value)
    case failed(AppError)
}
```

## 8. Effect와 취소 규칙

- 모든 외부 I/O는 TCA Dependency를 통해 Effect에서 실행한다.
- View의 `.task`는 Store에 lifecycle Action을 보내는 역할만 한다.
- 검색, 새로고침, 월 변경처럼 최신 요청만 유효한 작업은 `cancelInFlight` 정책을 명시한다.
- 화면 종료 시 더 이상 필요하지 않은 장기 Effect를 취소한다.
- 기반 네트워크 계층이 Swift Task 취소를 전달하지 못하는 경우에도 request ID와 취소 확인으로 stale state 반영을 막는다.
- 기반 Moya 요청 자체의 취소 전파는 별도 NetworkKit 기술부채 작업으로 유지한다.

## 9. 에러 처리 전환

현재 `ErrorHandling`은 참조 타입 ViewModel의 `currentError`를 직접 변경하므로 Reducer에서 재사용하지 않는다.

TCA Feature는 다음 형태의 에러 매핑 의존성을 사용한다.

```swift
struct AppErrorClient: Sendable {
    var map: @Sendable (any Error) -> AppError
}
```

전환 기간 정책:

- MVVM Feature는 기존 `ErrorHandling`을 유지한다.
- TCA Feature는 `AppErrorClient`를 사용한다.
- 모든 Feature 전환이 끝난 뒤 `ErrorHandling` 제거 여부를 결정한다.
- `.silent` 에러는 사용자 State에 노출하지 않는다.
- inline 에러와 서버 팝업을 동시에 표시하지 않도록 단일 정책을 둔다.

## 10. 단계별 전환

### Phase 0 — 도입 기반과 호환성 검증

#### 작업

- `Tuist/Package.swift`에 TCA 1.25.5를 고정 버전으로 추가한다.
- Tuist에서 여러 Feature 타깃이 TCA를 공유하는 연결 방식을 검증한다.
- Search 타깃에서 `@Reducer`, `@ObservableState`, `Store`, `TestStore` 컴파일을 확인한다.
- 최신 TCA에서 deprecated된 `@BindingState`, `ViewStore`, `BindingReducer(Action.view)` 패턴을 새 코드에서 사용하지 않는다.
- Search 타깃의 Swift 6 전환 범위를 결정하고 strict concurrency 경고를 확인한다.

#### 완료 조건

- `tuist install && tuist generate --no-open`이 성공한다.
- 빈 Search Reducer가 모듈과 테스트 타깃에서 컴파일된다.
- 기존 앱 기능과 테스트에 동작 변화가 없다.

### Phase 1 — Search 파일럿

#### 설계

```text
SearchFeature
├─ query
├─ searchPhase
├─ popularPhase
├─ presentedError
├─ ViewAction
├─ ResponseAction
└─ DelegateAction
```

인기 키워드는 첫 단계에서 별도 Reducer로 분리하지 않는다. 다른 화면 재사용, 독립 갱신 주기 또는 자체 복잡성이 생길 때 분리한다.

#### 검색 정책

- `queryChanged`는 State만 변경한다.
- submit과 인기 키워드 선택만 검색을 즉시 실행한다.
- 공백만 있는 검색어는 요청하지 않는다.
- 새 검색은 이전 검색 Effect를 취소한다.
- `requestID`가 현재 요청과 일치할 때만 결과를 반영한다.
- clear와 화면 종료는 진행 중인 검색을 취소한다.
- 디바운스와 자동 검색은 추가하지 않는다.

#### 변경 범위

- `SearchViewModel`을 `SearchFeature`로 교체한다.
- `SearchView`가 `StoreOf<SearchFeature>`를 받도록 변경한다.
- `SearchClient`가 기존 두 UseCase를 감싼다.
- `SearchBuilder`가 Store와 live dependency를 조립한다.
- Domain 모델에 필요한 `Equatable`과 `Sendable` 적합성을 추가한다.
- 기존 Search ViewModel 테스트를 `TestStore` 기반으로 변경한다.

#### 완료 조건

- View가 Feature State를 직접 대입하지 않는다.
- View가 검색용 `Task`를 직접 만들지 않는다.
- 기존 검색, 인기 키워드, retry, clear UX가 유지된다.
- 연속 검색에서 이전 응답이 최신 결과를 덮지 않는다.
- Search 테스트와 모듈 빌드가 통과한다.
- 기존 접근성 identifier가 유지된다.

### Phase 2 — Bookmark 전환

#### 검증할 패턴

- 관심사와 북마크 병렬 초기 로드
- 관심사와 정렬 Action
- 필터 변경 시 이전 목록 요청 취소
- 로그아웃 State 초기화
- 관심사 ID의 `Int?` 표현

관심사 ID 타입 수정은 TCA 구조 변경과 별도 커밋으로 분리한다.

#### 완료 조건

- View의 강제 언래핑과 문자열 ID 변환이 제거된다.
- 초기 로드, 필터, 정렬, 에러 상태를 TestStore로 검증한다.
- 기존 목록과 빈 화면 UX가 유지된다.

### Phase 3 — Subscribe 전환

#### 검증할 패턴

- active/paused 목록의 독립 State
- 초기 병렬 요청
- 탭별 새로고침
- newsletter ID별 pause/resume 중복 방지
- mutation Effect 성공과 실패

#### 완료 조건

- 동일 newsletter mutation의 중복 실행이 방지된다.
- 한 탭의 새로고침이 다른 탭의 데이터를 변경하지 않는다.
- 기존 Subscribe 테스트가 TestStore 기반으로 유지된다.

### Phase 4 — App Navigation 경계 전환

Search, Bookmark, Subscribe에서 패턴이 검증된 후 Navigation을 전환한다.

#### 순서

1. HomeStack의 Search 경로
2. SubscribeStack
3. BookmarkStack
4. ExploreStack
5. MyPageStack
6. Auth modal

#### 작업

- `AppFeature` 또는 탭별 상위 Feature가 Navigation State를 소유한다.
- Feature callback을 Delegate Action 처리로 교체한다.
- 탭별 push/pop/popToRoot 동작을 State 전이로 표현한다.
- 인증 modal과 로그인 완료 흐름을 상위 State에 연결한다.
- 각 탭 전환이 끝날 때 해당 기존 Router 경로만 제거한다.

#### 완료 조건

- Search Feature가 구체적인 탭 Router를 알지 않는다.
- 동일 Search Feature를 Home, Subscribe, Bookmark, Explore에서 재사용할 수 있다.
- 뒤로 가기, 브랜드 상세, 피드백 이동이 기존과 동일하게 동작한다.
- 전환된 경로에는 callback과 Delegate Action이 중복 존재하지 않는다.

### Phase 5 — 중간 난도 Feature 전환

다음 순서로 한 Feature씩 전환한다.

1. Mypage
2. Withdraw
3. Login
4. Signup
5. BrandDetail
6. Explore

입력 항목이 많은 Signup도 범용 Binding Action 하나에 모든 필드를 숨기지 않고 의미 있는 View Action을 우선한다.

```swift
case nicknameChanged(String)
case birthYearSelected(String)
case genderSelected(Gender)
case agreementToggled(Agreement)
case nextButtonTapped
```

### Phase 6 — Detail 전환

#### BrandDetail

- 상세 조회
- guest 조회
- pause/resume mutation
- 구독 상태 팝업

#### ArticleDetail

- WKWebView 이벤트를 `Action.webView(...)`로 변환한다.
- Highlight renderer를 TCA Dependency client로 격리한다.
- renderer 객체를 State에 저장하지 않는다.
- 장기 이벤트 스트림은 화면 종료 시 취소한다.
- 기존 Highlight command/event 모델과 테스트 전략을 유지한다.

### Phase 7 — Home 전환

Home은 마지막에 전환하며 기존 ViewModel을 그대로 하나의 거대한 Reducer로 번역하지 않는다.

```text
HomeFeature
├─ CalendarFeature
├─ ArticleListFeature
├─ HomeLoadClient
├─ HomeCacheClient
└─ DelegateAction
```

#### 먼저 분리할 책임

- 오늘/월/날짜별 데이터 로드
- 달력 선택과 월 변경
- 캐시와 인접 월 프리패치
- 읽음 처리
- 하이라이트 갱신
- 인증 상태 변경
- 최신 요청 판별

#### 완료 조건

- 월 변경과 날짜 선택의 race condition 테스트가 있다.
- 인접 월 프리패치가 화면 State를 잘못 덮지 않는다.
- 캐시 eviction과 최신 요청 정책이 테스트 가능하다.
- 인증 변경 시 모든 사용자 종속 State가 초기화된다.
- 기존 Home UseCase 테스트가 유지된다.

### Phase 8 — 레거시 제거

- 남아 있는 `*ViewModel`과 ViewModel 전용 mock을 제거한다.
- `ErrorHandling` 사용처가 없으면 제거한다.
- 전환 완료된 Builder callback을 제거한다.
- `AppCoordinator`와 `Router` 사용처가 없으면 제거한다.
- `CLAUDE.md`의 MVVM 규칙을 TCA 규칙으로 갱신한다.
- 아키텍처 문서와 모듈 템플릿을 갱신한다.

## 11. Feature 전환 우선순위

| 순서 | Feature | 난도 | 주요 검증 목적 |
|---:|---|---|---|
| 1 | Search | 낮음 | 기본 State/Action/Effect, 취소, TestStore |
| 2 | Bookmark | 낮음~중간 | 필터, 병렬 초기 로드, 타입 정리 |
| 3 | Subscribe | 중간 | 독립 목록, ID별 mutation |
| 4 | App Navigation | 중간~높음 | Delegate, 탭별 Stack State |
| 5 | Mypage/Withdraw | 중간 | 편집 상태, 성공 이벤트, 로그아웃 |
| 6 | Login/Signup | 중간~높음 | SDK Effect, 다단계 폼, 인증 Delegate |
| 7 | BrandDetail/Explore | 높음 | 복수 요청, 필터, 구독 mutation |
| 8 | ArticleDetail | 높음 | WebView 이벤트 스트림과 renderer |
| 9 | Home | 매우 높음 | 캐시, 프리패치, 요청 경쟁, Feature 조합 |

## 12. 테스트 전략

### Reducer 테스트

- View Action 이후의 State 변화
- Effect가 방출하는 Response Action
- 성공, 실패, 취소 상태
- 중복 요청 방지
- stale response 무시
- Delegate Action 발생
- 화면 종료 시 장기 Effect 종료

### Dependency 테스트

- 기존 UseCase가 Client Adapter를 통해 올바른 인자를 받는지 검증한다.
- Preview/Test dependency가 live network를 호출하지 않게 한다.
- 에러 mapper가 기존 `AppError` 정책과 동일하게 동작하는지 검증한다.

### 통합 테스트

- Builder가 live dependency로 Store를 생성하는지 확인한다.
- Feature Delegate가 올바른 탭 Navigation State를 변경하는지 확인한다.
- 인증 전환 후 탭과 사용자 State가 예상대로 초기화되는지 확인한다.

### UI 테스트

- 전체 시나리오를 UI 테스트로 중복하지 않는다.
- 검색 → 결과 선택 → 브랜드 상세처럼 Reducer만으로 검증하기 어려운 핵심 경로만 유지한다.
- 기존 accessibility identifier를 마이그레이션 중 변경하지 않는다.

## 13. PR 및 커밋 단위

권장 PR 순서는 다음과 같다.

1. TCA/Tuist 기반 및 Search Swift 호환성
2. SearchClient, AppErrorClient
3. SearchFeature와 TestStore
4. SearchView와 Builder 연결
5. BookmarkFeature
6. SubscribeFeature
7. HomeStack Search Navigation
8. 나머지 탭 Navigation
9. 중간 난도 Feature를 하나씩 전환
10. ArticleDetail
11. Home
12. 레거시 제거와 문서 갱신

각 PR은 다음을 만족해야 한다.

- 독립적으로 빌드·테스트 가능하다.
- 기존 사용자 동작을 유지한다.
- 생성된 `project.pbxproj`를 직접 편집하지 않는다.
- 관련 모듈 `scripts/test.sh <Scheme>`와 `scripts/build.sh <Scheme>`을 실행한다.
- 전환되지 않은 MVVM Feature의 동작을 변경하지 않는다.

## 14. 위험과 대응

### 최신 TCA와 2.0 전환 준비

TCA 1.24 이상에서 오래된 Binding 및 ViewStore API가 deprecated되었다. 새 코드는 1.25.5의 Observation 기반 API만 사용하고, 과거 블로그 예제를 그대로 복사하지 않는다.

### Swift 언어 모드 불일치

앱 타깃은 Swift 6이지만 Feature 타깃은 현재 Swift 5 모드다. TCA 파일럿에서 Search만 먼저 Swift 6 호환성을 확인하되, 공통 Tuist 설정 변경으로 모든 Feature를 한 번에 전환하지 않는다.

### 멀티모듈 패키지 링크

여러 static framework가 TCA를 직접 링크할 때 중복 링크와 테스트 타깃 의존성 문제가 생길 수 있다. Phase 0에서 공통 연결 방식을 검증하고, 테스트 타깃에 TCA를 불필요하게 중복 링크하지 않는다.

### 혼합 Navigation

MVVM callback과 TCA Delegate가 장기간 공존하면 이벤트가 중복 실행될 수 있다. 탭 경로 단위로 소유권을 명시하고, 한 경로의 전환이 끝나면 이전 callback을 즉시 제거한다.

### Reducer 비대화

큰 ViewModel을 한 Reducer로 기계적으로 변환하지 않는다. 독립적인 State, lifecycle, Effect 또는 재사용 경계가 확인될 때만 Child Feature로 분리한다.

### 네트워크 취소 미전파

현재 Swift Task 취소가 기반 Moya 요청까지 전달되지 않을 수 있다. TCA cancellation과 request ID로 State 오염을 막고, 실제 요청 취소는 NetworkKit 작업으로 별도 해결한다.

## 15. 롤백 전략

- Feature 단위로 기존 ViewModel 구현을 유지할 수 있는 PR 크기를 지킨다.
- Navigation 전환 전에는 기존 callback API를 호환 경계로 유지한다.
- 파일럿 평가가 실패하면 TCA 패키지와 Search 관련 변경만 되돌릴 수 있어야 한다.
- Domain/Data 계층을 변경하지 않아 MVVM 구현으로 복귀할 수 있게 한다.

## 16. 전체 완료 조건

- [ ] 모든 Feature의 상태 변경이 Reducer를 통한다.
- [ ] View에서 비즈니스 비동기 작업을 직접 실행하지 않는다.
- [ ] 모든 외부 I/O가 Dependency Effect로 격리된다.
- [ ] 취소 가능한 Effect에 명시적인 취소 정책과 테스트가 있다.
- [ ] Feature 외부 이동이 Delegate Action을 통해 상위 Navigation State로 전달된다.
- [ ] 기존 `AppCoordinator`, `Router`, ViewModel callback이 제거된다.
- [ ] `ErrorHandling` 또는 대체되지 않은 MVVM 전용 코드가 제거된다.
- [ ] 전체 모듈 테스트와 앱 빌드가 통과한다.
- [ ] 기존 주요 사용자 경로와 접근성 identifier가 유지된다.
- [ ] 아키텍처 문서와 개발 규칙이 TCA 기준으로 갱신된다.

## 17. 열린 결정

- TCA를 각 Feature 타깃에 직접 연결할지, 공통 Architecture 모듈을 둘지 Phase 0 빌드 스파이크에서 결정한다.
- Search 파일럿에서 Navigation callback을 유지할지, HomeStack의 최소 상위 Reducer까지 함께 만들지 PR 범위를 확정한다.
- Search 타깃만 Swift 6으로 전환할 수 있도록 Project helper 옵션을 추가할지 결정한다.
- TCA 2.0 정식 릴리스 전까지 1.25.5 고정 정책을 유지할지 정기 검토 주기를 정한다.

## 18. 참고 자료

- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [TCA 1.25.5 Package manifest](https://raw.githubusercontent.com/pointfreeco/swift-composable-architecture/1.25.5/Package.swift)
- [Newdok 기술부채](technical-debt.md)
- [Newdok 아키텍처 리뷰](architecture-review.md)
