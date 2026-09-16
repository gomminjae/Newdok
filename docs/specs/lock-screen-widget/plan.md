# Plan: 잠금화면 뉴스레터 요약 위젯

> **어떻게.** 홈의 최신 상태를 작은 App Group snapshot으로 공유하고, WidgetKit이 이를 읽어 원형·직사각형 accessory widget으로 표시한다.

## 영향 모듈

- `Workspace.swift`: `Modules/NewdokWidget` 프로젝트 등록
- `Modules/NewdokWidget`: WidgetKit app extension, provider, entry view, entitlements
- `Modules/Shared`: App Group snapshot 모델·저장소·widget kind 상수
- `Modules/Features/Home/Domain`: 위젯 snapshot publisher 프로토콜
- `Modules/Features/Home`: `HomeViewModel` publisher 주입 및 갱신 지점
- `Modules/App`: publisher 구현, App Group 설정, Home DI 연결, deep link 처리
- `docs/specs/lock-screen-widget`: 기능 스펙·계획·작업 목록

## 설계

### 데이터 모델과 저장

`Shared`에 다음 값을 `Codable & Sendable` snapshot으로 둔다.

```swift
WidgetHomeSummary(
    date: Date,
    todayTotalCount: Int,
    unreadCount: Int
)
```

- App Group `UserDefaults`에는 snapshot을 encoded `Data`로 저장한다.
- `date`는 오늘 여부를 판별하는 기준으로 사용한다.
- 저장소는 App Group ID만 보유하고, 매 읽기·쓰기 시 `UserDefaults(suiteName:)`를 사용해 공유 상태의 수명과 concurrency 경계를 작게 유지한다.
- App Group ID는 Debug/Release xcconfig의 기존 `APP_GROUP_ID`를 사용한다.

### 의존성 방향과 데이터 흐름

```text
HomeViewModel (@MainActor)
    └─ TodayWidgetSummaryPublishing (HomeDomain)
    └─ WidgetHomeSummaryPublisher (App)
            ├─ AppGroupWidgetHomeSummaryStore (Shared)
            └─ WidgetCenter.reloadTimelines (WidgetKit)

NewdokWidget
    └─ AppGroupWidgetHomeSummaryStore (Shared)
```

- `Home`은 `WidgetKit`을 직접 import하지 않는다.
- `HomeBuilder`/`HomeDIContainer`가 `TodayWidgetSummaryPublishing?`을 `HomeViewModel`에 주입한다.
- 테스트와 Example에서는 publisher를 생략할 수 있도록 기본값을 유지한다.

### snapshot 갱신 시점

- `loadToday()`가 오늘 articles를 read status까지 반영한 뒤 전체 수와 미읽음 수를 publish한다.
- `markArticleAsRead(articleId:)`가 오늘 날짜를 대상으로 처리된 경우에만 다시 publish한다.
- 과거 날짜를 보고 있는 상태에서 읽음 처리한 경우에는 위젯 snapshot을 변경하지 않는다.
- `resetForAuthChange()`에서는 이전 계정의 snapshot을 clear해 위젯에 남지 않게 한다.

### 위젯 UI

- `StaticConfiguration`을 사용한다.
- `.accessoryCircular`: envelope 아이콘과 큰 미읽음 수를 표시한다.
- `.accessoryRectangular`: `오늘 도착 N개`와 `미읽음 M개`를 두 줄 계층으로 표시한다.
- 제목·이미지·브랜드명은 1차 범위에서 제외해 Lock Screen의 좁은 폭과 개인정보 노출을 피한다.
- snapshot이 없거나 기준 날짜가 오늘이 아니면 두 count를 `0`으로 표시한다.
- timeline은 현재 entry 하나와 다음 자정 갱신 정책으로 구성한다.
- `widgetURL(URL(string: "newdok://home"))`로 기존 URL scheme을 사용한다.

### 앱 진입

`NewdokApp`의 `onOpenURL`에서 `newdok://home`을 식별하면 `AppRouter.navigate(to: .home)`를 호출한다. 기존 Kakao 로그인 URL 처리는 유지한다.

### 테스트와 검증

- `HomeTests`: load, 오늘의 read 처리, 과거 날짜 read 처리, auth reset 시 publisher 호출 값을 검증한다.
- `Shared` 저장소는 App Group이 없는 환경과 손상된 Data를 빈 상태로 처리하는지 검증한다.
- Widget preview에서 0, 한 자리 수, 두 자리 수를 확인한다.
- `tuist generate --no-open` 후 Debug 빌드와 실제 기기 Lock Screen에서 원형·직사각형을 확인한다.

## 의존성 / 외부 연동

- 새 외부 의존성은 추가하지 않는다.
- 시스템 프레임워크 `WidgetKit`만 Widget Extension과 App publisher에서 사용한다.
- App Group capability는 App과 Widget Extension 양쪽 entitlements에 동일한 설정을 사용한다.

## 엣지 케이스 / 에러 처리

- App Group ID가 비어 있거나 치환되지 않았으면 publisher가 앱 흐름을 막지 않고 publish를 건너뛴다.
- snapshot Data decode 실패는 로그를 남기지 않고 빈 상태로 fallback한다. 사용자 데이터나 원문 응답은 로그에 남기지 않는다.
- 자정 이후 오래된 snapshot은 Widget provider가 무시한다.
- WidgetKit이 즉시 reload하지 않더라도 다음 timeline 갱신에서 최신 저장 값을 읽는다.
- 게스트 상태에서는 개인화된 count를 publish하지 않는다.
- 유효한 토큰 없이 앱이 시작되면 App composition root에서 snapshot을 먼저 비운다.

## 위험 / 트레이드오프

- WidgetKit 업데이트는 예산 기반이므로 앱을 열지 않은 동안 서버 변경이 즉시 반영되지 않을 수 있다.
- count-only MVP로 시작해 공간 제약·프라이버시 위험을 낮춘다. 브랜드명이나 최신 기사 정보는 실제 사용성을 확인한 뒤 별도 결정한다.
- 기존 `feature/lock-screen-widget` 브랜치는 이전 아키텍처의 구현이므로 cherry-pick하지 않고 현재 `HomeViewModel`/DI 구조에 맞춰 재구성한다.
