# Tasks: 전체 Swift 6 전환과 타입 안전성 검토

- [x] 사용자 요청 범위와 현재 Xcode·Swift·워크스페이스 설정 확인
- [x] 기존 로컬 변경 백업 및 승인된 spec·plan 기록
- [x] 공통 Tuist 설정을 모든 자체 타깃의 Swift 6으로 전환
- [x] Core의 Sendable·전역 상태·날짜·URL 경계 수정
- [x] Feature·Testing·Tests·Example의 격리 오류 수정
- [x] 북마크 ID와 강제 변환·문법 검토 및 회귀 검증
- [x] tuist install / generate
- [x] 전체 테스트와 Example 빌드
- [x] fastlane build와 최종 설정·diff 검증
- [x] 검토 결과 및 수용 조건 기록

## 검증 기록

- 시작 환경: Xcode 27.2 (27B52), Apple Swift 6.4.2, iOS SDK 27.2. 설치된 iOS 27.0 시뮬레이터를 우선 사용한다.
- `./scripts/test.sh --device 'iPhone 18 Pro' --os 27.0 --no-selective-testing --result-bundle-path /private/tmp/newdok-swift6-tests-final.xcresult` 성공. xcresult 요약: Passed, totalTestCount 169, passedTests 169, failedTests 0, skippedTests 0, runtimeWarnings 없음. 매개변수 조합을 포함한 기기별 실행 수는 186회다.
- 워크스페이스의 자체 67개 타깃에서 프로젝트·타깃 설정을 합산해 Debug·Release의 SWIFT_VERSION=6.0, SWIFT_STRICT_CONCURRENCY=complete를 확인했다. 기존 미추적 NewdokWidget은 워크스페이스 대상이 아니므로 보존했다.
- `xcodebuild ... -scheme Newdok-Workspace ... build-for-testing` 성공. Bookmark·Detail·Explore·Home·Mypage·Search·Subscribe Example 7개가 워크스페이스 build action에 포함돼 실제 컴파일됐다. 최종 전체 테스트에서도 이 build action을 사용했다.
- FoundationKit에 날짜·입력 검증 테스트와 실행 가능한 test.sh를 등록했다. API URL 검증과 북마크 관심사 ID 전달 회귀 테스트도 추가했다.
- `python3 scripts/check-codegraph.py` 성공: 자체 Swift 515개, 인덱스 527개, 누락·중복·제외 경로 없음. `git diff --check`, Fastfile의 `ruby -c` 통과.
- `fastlane build` 성공: 2026-11-07 16:46:58, Xcode 27.2 / iOS 27.2 SDK의 Release·generic/platform=iOS clean build. 서명 설정을 변경하지 않았으며 기존 skip_archive=true에 따라 archive·업로드는 하지 않았다. 로그: /private/tmp/newdok-swift6-release-3.log.
- 앞선 fastlane 시도는 기존 before_all의 영구적인 Dir.chdir로 인해 workspace를 저장소 상위에서 찾아 실패했다. Tuist 실행의 Dir.chdir를 블록으로 제한해 Fastlane action의 작업 디렉터리를 복원한 뒤 통과했다.
- 사용자 확인 요청에 따라 iPhone Duo 기기와 전용 iOS 27.2 런타임이 모두 설치됨을 확인했다. 기기는 Shutdown 상태로 보존했으며 Duo에서 앱 UI를 실행·검증한 것은 아니다.

## 문법·타입·동시성 검토

- 자체 production 소스의 nonisolated(unsafe)와 @unchecked Sendable은 0개다. 전체 자체 코드의 강제 try·강제 cast도 0개다.
- 남은 @unchecked Sendable 한 곳은 NetworkKit 테스트의 HangingProvider다. 외부 MoyaProvider 상속 제약 때문에 유지하며, 하위 타입은 불변 actor 참조만 저장한다는 기존 동기화 근거를 보존했다.
- Moya의 preconcurrency import는 외부 SDK 경계에 한정한다. 자체 MoyaTarget은 Sendable인 요청을 보관하고 Moya.Task의 Any/Encodable 표현은 SDK에 전달할 때만 만든다. 취소 처리 operation도 Sendable로 검사한다.
- 비동기 mock은 MainActor에, 동기 mock·저장소 stub은 Mutex에 가변 상태를 둔다. Domain에서 작업 경계를 넘는 값 모델은 Sendable로 검사한다.
- 로그인 함수는 직접 await할 수 있으며 테스트의 임의 sleep과 공유 AppState 의존을 제거했다. Apple 로그인 manager는 MainActor에서 callback을 먼저 소비하고 Task 취소를 authorization controller에 전달한다.
- 무시되던 throwing Task의 취소를 처리하고 자동 포커스는 .task에 묶었다. WebView 자동 입력 작업은 페이지 이동·해제 시 취소한다. 외부 페이지의 일시적인 JS 실패는 기존 재시도 동작을 유지한다.
- URL 문자열 강제 변환을 없애고 API 설정 경계에서 HTTP(S) URL을 검증한다. 북마크 관심사 ID는 Int?로 전달하며 전체 선택은 nil이다. 고정된 약관 URL과 개수 확인 후의 배열 first는 기존 불변식이 확인돼 불필요한 추상화를 추가하지 않았다.
- SwiftData predicate와 MainActor 접근은 그대로 Swift 6 컴파일에 통과했다. 전체 fetch 우회나 preconcurrency import를 추가하지 않았다.
- 기존 Tuist 설정 파일 deprecation, 외부 패키지 watchOS 지원 버전, 생성 프로젝트 umbrella header, App의 AccentColor 에셋 경고는 이번 Swift 6 문법 변경과 구분한다. 직접적인 자체 Swift 동시성 오류·미처리 throwing Task 경고는 해소됐다.
- Apple·Kakao 실제 인증 UI와 외부 구독 페이지 자동 입력은 수동 검증하지 않았다. 단위 테스트는 SDK mock·stub을 사용한다.

## 후속 Duo 실행 검증 (2026-11-07)

- 사용자 요청으로 Xcode 27.2 (27B52), iOS 27.2 SDK의 Debug 앱을 Duo 전용 런타임 27.2 (24B91016s)에 설치·실행했다. 앱 버전 1.1.0, 빌드 1, bundle ID com.newdok.test다.
- `xcodebuild -workspace Newdok.xcworkspace -scheme Newdok -configuration Debug -destination 'id=8B171830-AACC-42CE-9029-4EE684A278A1' CODE_SIGNING_ALLOWED=NO build` 성공. 로그: /private/tmp/newdok-duo-build.log.
- 첫 부팅 bootstatus는 Data Migration Failed를 보고했지만 홈 화면 진입과 앱 설치·실행은 정상 동작했다. 앱 크래시로 해석하지 않는다.
- 온보딩 → 로그인 화면 → 비회원 이용으로 진입했다. 접힌 외부 화면에서 시스템 TabView가 오른쪽 세로 탭바로 자동 배치됐다. Duo 전용 탭바 분기를 원복한 상태에서도 SDK 재빌드로 적용됨을 확인했다.
- 홈 선택 상태에서 펼쳐 내부 가로 화면으로 전환됐고 세로 탭바와 홈 선택이 유지됐다. 둘러보기 탭의 목록 로드와 뉴스레터 상세 진입도 확인했다.
- 발견: 펼친 내부 가로 화면에서 홈 상단 로고와 검색 아이콘 일부가 화면 위쪽으로 잘린다. simctl 원본 캡처와 Device Hub의 실제 기기 표시 양쪽에서 확인했다. 원인 수정은 이번 확인 작업에서 수행하지 않았다.
- 추가 회전 조작은 Device Hub 컴퓨터 사용 승인 거절로 실행되지 않았다. 열린 세로 화면, 펼침에서 다시 접기, 상세에서 뒤로 복귀, 로그인 후 구독·토스트는 검증하지 않았다. 앱은 Duo의 비회원 상세 화면에 실행된 상태다.
- 캡처: [접힌 홈](../../../build/verification/duo-20261107/closed-home.png), [펼친 홈](../../../build/verification/duo-20261107/open-home.png), [펼친 상세](../../../build/verification/duo-20261107/open-detail.png). PNG는 기존 build 제외 경로에 보관했다.

## 후속 버전 지정 (2026-11-07)

- App Store Connect에서 현재 배포 버전 1.1.0 (빌드 5)을 읽기 전용으로 확인했다.
- 사용자 요청에 따라 다음 앱 버전을 1.1.1로 지정했다. 기준 설정은 Modules/App/Project.swift의 MARKETING_VERSION이며 현재 로컬 CURRENT_PROJECT_VERSION=1과 배포 lane의 빌드 번호 자동 계산은 유지한다.
- 위 테스트·Duo 캡처는 버전 변경 전 1.1.0 (1)로 수행한 기록이다. 버전 변경은 배포를 뜻하지 않는다.
- Tuist install·generate 완료. 생성된 App 프로젝트의 Debug·Release 모두 MARKETING_VERSION=1.1.1, CURRENT_PROJECT_VERSION=1을 확인했고 git diff --check가 통과했다.

## 1.1.1 Release·Debug 아카이브 (2026-11-07)

- 사용자 요청으로 두 구성의 실제 기기용 archive를 생성했다. 기존 자동 서명을 사용했으며 인증서·프로비저닝 설정을 변경하지 않았다.
- Release: `/Users/minjae/Library/Developer/Xcode/Archives/2026-11-07/Newdok-1.1.1-Release-20261107083942.xcarchive`, `com.newdok.app`, 1.1.1 (1).
- Debug: `/Users/minjae/Library/Developer/Xcode/Archives/2026-11-07/Newdok-1.1.1-Debug-20261107083942.xcarchive`, `com.newdok.test`, 1.1.1 (1). dSYM을 포함하도록 archive 명령에만 `DEBUG_INFORMATION_FORMAT=dwarf-with-dsym`을 지정했다.
- 두 구성 모두 ARCHIVE SUCCEEDED. 아카이브의 앱 메타데이터, arm64 아키텍처, iPhoneOS 27.2 SDK, 서명(`codesign --verify --deep --strict`), embedded provisioning profile, 앱과 dSYM의 UUID 일치를 검증했다. 각 아카이브에는 dSYM 7개가 있다.
- 검증 JSON: `build/archives/Newdok-1.1.1-20261107083942/verification.json`. 로그: `/private/tmp/newdok-1.1.1-release-archive.log`, `/private/tmp/newdok-1.1.1-debug-archive.log`.
- IPA export, Crashlytics 심볼 업로드, TestFlight·App Store 배포는 실행하지 않았다.

## 후속 App Store Connect 업로드 (2026-11-07)

- 사용자가 Release·Debug 두 아카이브의 업로드를 명시적으로 요청했다. 시작 시 두 앱 모두 1.1.1 빌드는 없었다. 직전 빌드는 상용 1.1.0 (5), 개발 1.1.0 (9)였다.
- 새 인증서·프로파일을 만들지 않고, Apple 로그인 권한이 포함된 기존 App Store 배포 프로파일과 로컬 배포 인증서를 선택해 두 아카이브를 export했다. 버전·빌드 자동 변경을 꺼 1.1.1 (1)을 유지했다. 두 구성 모두 EXPORT SUCCEEDED.
- Release IPA: `build/uploads/Newdok-1.1.1/Release/`, Debug IPA: `build/uploads/Newdok-1.1.1/Debug/`. 각 verification.json에 번들 ID, 버전, 빌드 번호, IPA 경로와 SHA-256을 기록했다.
- Pilot API-key 인증으로 두 IPA를 App Store Connect에 업로드했다. Release는 18:09:31, Debug는 18:09:43에 전송 성공 및 서버 접수를 확인했다.
- 업로드 접수 기록: `build/uploads/Newdok-1.1.1/upload-verification.json`. 로그에는 API 키 식별자와 경로를 가려 기록했다.
- 18:13경 App Store Connect API에서 두 앱의 1.1.1 (1) 빌드가 모두 processingState=VALID로 등록됨을 확인했다. 각 Connect build ID와 업로드 일시는 위 검증 JSON에 기록했다.
- 업로드 전용으로 실행했으며 App Store 심사 제출, 공개 출시, 외부 테스터 배포·알림, Crashlytics 심볼 업로드는 실행하지 않았다.
