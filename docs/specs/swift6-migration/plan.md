# Plan: 전체 Swift 6 전환과 타입 안전성 검토

## 영향 모듈

Tuist 공통 helper, App, 모든 Core·Feature 및 자체 테스트·Example. 새 모듈·의존성 없음.

## 설계

- Project.feature·Project.module의 프로젝트 기본 설정으로 Swift 6과 complete 검사를 전달해 테스트·Example까지 포함한다.
- 컴파일 오류는 Core에서 Feature·App 순으로 실제 격리와 Sendable 값 모델을 수정한다. UI 상태는 MainActor에 유지한다.
- 동기 전역 레지스트리는 기존 호출 API를 보존하면서 Mutex 안에 상태를 둔다. 불변 저장소의 불필요한 unchecked 적합성을 검토한다.
- ISO 날짜 파서는 Sendable 값 타입을 사용하고 소수 초·시간대 형식 호환성을 테스트한다.
- 북마크 관심사 ID는 내부에서 Int?로 전달하고 HTTP query에서 String으로 변환한다. URL은 설정 경계에서 검증한다.
- 문법 검토는 강제 언래핑, 강제 캐스트·try, 콜백 수명·취소, 불필요한 타입 소거와 격리 우회에 집중한다. 단순 스타일 재작성은 하지 않는다.
- 로그인 단발성 작업은 직접 await할 수 있게 하여 내부 Task와 테스트의 임의 sleep을 제거한다. 버튼에서 비동기 작업을 시작하고 화면의 로그인·회원가입 callback 계약은 보존한다. 테스트 인증 상태는 개별 AppState를 주입한다.

## 의존성 / 외부 연동

- 외부 SDK의 소스·언어 설정은 변경하지 않는다. 필요한 preconcurrency import는 SDK 계약과 실제 호출 경계를 확인하고 근거를 기록한다.
- 프로젝트는 Tuist 4.143.0으로 재생성한다. 생성 pbxproj·scheme는 직접 수정하지 않는다.
- Release 검증 과정에서 before_all의 영구적인 Dir.chdir 때문에 Fastlane action이 저장소의 상위 폴더로 한 번 더 이동하는 기존 오류를 확인했다. Tuist 실행만 Dir.chdir 블록으로 감싸 작업 디렉터리를 복원한다. 서명·인증서·업로드 동작은 변경하지 않는다.

## 엣지 케이스 / 에러 처리

- 취소와 중복 callback은 continuation을 한 번만 종료한다. 취소된 응답은 UI 상태를 덮어쓰지 않는다.
- SwiftData의 predicate를 유지하며 전체 fetch 우회는 하지 않는다.
- 테스트는 기존 하네스를 사용하며 추가 테스트 타깃이 필요하면 모듈 test.sh와 함께 등록한다.

## 위험 / 트레이드오프

- Xcode 업데이트 후 시뮬레이터·외부 의존성 경고는 앱 코드 오류와 구분한다.
- 시작 시 기존 생성 프로젝트·Derived·buildServer.json과 미추적 위젯·성능 스펙·이미지 변경을 보존한다. 백업은 /private/tmp/newdok-swift6-before-1cq7dnri에 있다.
