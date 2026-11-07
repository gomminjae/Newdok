# Spec: 전체 Swift 6 전환과 타입 안전성 검토

> Status: done — 2026-11-07 사용자가 승인한 전체 Swift 6 전환과 문법 검토를 완료했다.

## 배경 / 문제

App만 Swift 6 언어 모드이고 자체 Core·Feature·테스트 타깃은 Swift 5 모드다. 동시성 검사를 경고 수준에 남겨 두지 않고 자체 코드 전체에서 검증한다.

## 목표 (Goals)

- 워크스페이스의 모든 자체 타깃(Interface·Domain·Data·Feature·Testing·Tests·Example 포함)을 Swift 6 언어 모드로 전환한다.
- 격리 경계와 Sendable 적합성을 실제 소유 관계에 맞추고, 불필요한 unsafe 우회를 제거한다.
- 기존 동작을 보존하면서 URL 구성, 관심사 ID, 입력 검증 등 확인된 타입 안전성 문제와 문법을 검토한다.

## 비목표 (Non-goals)

- 외부 패키지의 언어 모드 변경, 새 의존성 도입, 화면 디자인·로그인·Duo 전용 동작 변경.
- 최소 지원 iOS 18.0, iPhone 전용 설정, 인증서·배포·기존 로컬 위젯 변경.
- 일괄 재포맷과 동작에 무관한 이름 변경.

## 유저 스토리

- 개발자는 자체 모듈을 Swift 6으로 빌드하여 동시성 오류를 컴파일 단계에서 발견한다.

## 수용 조건 (Acceptance Criteria)

- [x] 모든 워크스페이스 자체 타깃의 Debug·Release 언어 모드는 Swift 6이고 strict concurrency는 complete다.
- [x] 전역 레지스트리의 nonisolated(unsafe)를 제거하고, 새 unsafe 격리 우회를 추가하지 않는다.
- [x] 날짜 파싱·북마크 필터·요청 URL의 기존 계약을 유지하고 관련 회귀 검증을 수행한다.
- [x] 변경한 비동기 테스트와 mock은 Swift 6 검사에 통과하며 실제 네트워크·임의 sleep에 의존하지 않는다.
- [x] 전체 테스트와 fastlane build를 실행하고 결과 및 환경 제약을 기록한다.
- [x] 워크스페이스에 등록된 7개 Example 타깃도 Swift 6 빌드를 확인한다.
- [x] 검토 결과와 남은 외부 SDK 경계를 기록한다.

## 열린 질문

- 없음. Xcode 27.2 / Swift 6.4.2를 사용하고 Swift 언어 모드는 6으로 설정한다.
