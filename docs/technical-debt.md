# Technical Debt

현재 동작을 유지하면서 별도 작업으로 처리할 기술부채를 기록한다. 새로운 추상화는 실제 요구가 생길 때만 도입하고, 아래 항목은 명시된 완료 조건까지만 수정한다.

## P1 — Swift 6 언어 모드 정합성

- 현황: App은 Swift 6이지만 Shared, FoundationKit, DatabaseKit과 Feature 모듈은 생성된 프로젝트에서 Swift 5 모드다.
- 위험: `SWIFT_STRICT_CONCURRENCY = complete` 경고가 Swift 6에서 컴파일 오류로 승격된다.
- 작업:
  - 잔여 동시성 경고를 먼저 해소한다.
  - 의존성 leaf 모듈부터 `SWIFT_VERSION = 6.0`을 적용한다.
  - Tuist 설정을 수정하고 생성된 `project.pbxproj`는 직접 편집하지 않는다.
- 완료 조건: 전체 앱이 Swift 6 모드에서 동시성 오류 없이 빌드된다.

## P1 — ISO 8601 파서 동시성

- 위치: `Modules/FoundationKit/Sources/Date/Date+NewdokFormat.swift`
- 현황: `ISO8601DateFormatter` 정적 인스턴스 두 개가 non-Sendable 공유 상태 경고를 만든다.
- 작업: 가능한 경우 값 타입인 `Date.ISO8601FormatStyle` 기반 파싱으로 교체한다.
- 완료 조건: 해당 동시성 경고가 사라지고 기존 날짜 파싱 테스트가 통과한다.

## P1 — 네트워크 Task 취소 전파

- 위치: `Modules/NetworkKit/Sources/Network/Core/Error/MoyaProvider+Async.swift`
- 현황: Swift `Task` 취소가 Moya의 `Cancellable`에 전달되지 않는다.
- 위험: 화면이 사라지거나 새 요청으로 교체돼도 이전 요청이 계속 실행되고 늦은 응답이 상태를 덮을 수 있다.
- 작업: `withTaskCancellationHandler`로 Swift Task와 Moya 요청 취소를 연결한다.
- 완료 조건: Task 취소 시 기반 요청도 취소되고 continuation이 정확히 한 번 종료된다.

## P2 — SwiftData Predicate 경고

- 위치: `Modules/DatabaseKit/Sources/DefaultHighlightLocalDataSource.swift`
- 현황: SwiftData 매크로가 생성한 `ReferenceWritableKeyPath`의 Sendable 경고가 발생한다.
- 작업: MainActor 격리를 유지하면서 최소 범위의 `@preconcurrency import SwiftData` 또는 SDK가 지원하는 정식 격리 방식을 적용한다.
- 금지: 경고 제거만을 위해 전체 fetch 후 메모리 필터링으로 성능을 낮추지 않는다.
- 완료 조건: Swift 6 모드 빌드가 통과하고 SwiftData 접근은 MainActor에 남는다.

## P2 — Bookmark 관심사 ID 타입

- 위치: Bookmark Domain, Data, ViewModel, View
- 현황: 관심사 ID를 `String`과 빈 문자열로 표현하며 View에서 `Int`를 강제 언래핑해 변환한다.
- 작업: 앱 내부에서는 `Int?`를 사용하고 HTTP query 생성 경계에서만 `String`으로 변환한다.
- 완료 조건: `id!`가 제거되고 “전체” 선택은 `nil`로 표현된다.

## P2 — 전역 레지스트리 동기화

- 위치:
  - `Modules/Shared/Sources/Error/AppError.swift`
  - `Modules/Shared/Sources/Error/ErrorContext.swift`
- 현황: `NSLock`과 `nonisolated(unsafe)` 조합으로 전역 상태를 보호한다.
- 작업: 값을 `Synchronization.Mutex` 내부로 이동해 unsafe 격리 우회를 제거한다.
- 완료 조건: `nonisolated(unsafe)` 없이 기존 등록·조회 동작과 스레드 안전성이 유지된다.

## P3 — 네이밍 일관성

- `fetchuserInfo` → `fetchUserInfo`
- `shownicknameToast` → `showNicknameToast`
- `orderOpt` → 문맥에 따라 `sortOrder` 또는 `orderOption`
- `isShowFilterSheet` → `isFilterSheetPresented`
- `isShowSortSheet` → `isSortSheetPresented`
- `initialLoaded`와 `isInitialLoaded` → `hasLoadedInitially`로 통일
- 완료 조건: 동작 변경 없이 선언과 모든 호출부 이름만 일관되게 변경된다.

## 보류 — 요구가 생길 때만 검토

- `AccessToken`/`RefreshToken` wrapper 타입
- 모든 Bool 상태의 enum 전환
- 모든 저장소와 싱글톤의 actor 전환
- 탭이 두 개인 화면의 전면적인 enum 추상화
- Moya 교체 또는 네트워크 계층 전면 재작성
