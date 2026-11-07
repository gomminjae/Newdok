# Technical Debt

현재 동작을 유지하면서 별도 작업으로 처리할 기술부채를 기록한다. 새로운 추상화는 실제 요구가 생길 때만 도입하고, 아래 항목은 명시된 완료 조건까지만 수정한다.

## Swift 6 전환에서 정리한 항목 (2026-11-07)

- 모든 자체 타깃의 Swift 6 언어 모드와 complete 동시성 검사를 공통 Tuist 설정에 적용했다. Testing·Tests·Example도 포함한다.
- ISO 날짜 파서를 Sendable인 `Date.ISO8601FormatStyle`로 교체하고 소수 초·시간대 파싱을 회귀 검증한다.
- Moya 요청 취소 전파는 기존 구현을 유지하고, 요청 모델과 취소 처리 클로저의 Sendable 경계를 명시했다.
- SwiftData의 MainActor 접근과 predicate를 유지했다. Xcode 27.2 SDK에서 Swift 6 컴파일에 통과해 추가 격리 우회가 필요하지 않았다.
- 북마크 관심사 ID는 내부에서 `Int?`로 전달하고 HTTP query 경계에서만 문자열로 변환한다.
- 전역 오류 레지스트리의 `NSLock`·`nonisolated(unsafe)` 조합을 `Synchronization.Mutex`로 교체했다.
- API base URL은 설정 경계에서 HTTP(S) URL로 검증한다. 입력 검증은 강제 `try` 대신 컴파일 시 검사되는 정규식 리터럴을 사용한다.
- 검증 결과와 외부 SDK 경계는 [Swift 6 전환 기록](specs/swift6-migration/tasks.md)에 남긴다.

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
