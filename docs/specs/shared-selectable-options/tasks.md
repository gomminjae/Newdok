# Tasks: 공통 선택 목록과 앱 시작 책임 분리

- [x] 실제 소비처·Builder/DI·모듈 의존성을 확인하고 설계 승인 기록
- [x] 공통 모델·조회 계약·단순 async 조회와 준비/재시도 구현 (공유 Task·continuation 제외)
- [x] Shared 테스트 타깃·실행 가능한 test.sh·격리된 fixture 테스트 추가
- [x] App HTTP 구현과 단일 저장소 DI 연결, Explore 소유 옵션 조회 제거
- [x] Auth·Explore·MyPage의 영역별 준비·상태·재시도·입력 검증 연결
- [x] 회원가입 관심사 하드코딩 제거와 Example fixture 갱신
- [x] 앱 시작의 옵션 preload·고정 대기·인증 전 숨겨진 탭 생성 제거
- [x] Tuist install/generate 및 codegraph 소스 검증
- [x] 전체 테스트·Release 빌드·diff 검증 및 결과 기록

## 검증 기록

- Xcode 27.0 기본 Swift 6.4를 명령 환경으로 지정해 install/generate 성공. 별도 Swiftly 6.2.3과 SDK 혼용은 설치 단계에서 실패하므로 프로젝트 설정 변경 없이 PATH/TOOLCHAINS만 지정했다.
- 후속 수정: 저장소 루트 `.swift-version`을 `xcode`로 지정했다. Swiftly가 이 프로젝트에서만 선택된 Xcode의 Swift를 사용하므로 이제 환경변수 없이 `tuist generate --no-open`과 고정 버전의 `mise exec -- tuist generate --no-open`이 모두 성공한다. 전역 Swiftly 기본값·셸 설정은 변경하지 않았다.
- `./Modules/Shared/test.sh` 성공. `python3 scripts/check-codegraph.py`는 자체 Swift 511개·인덱스 523개, 누락/중복/제외 경로 없음으로 통과했다.
- `./scripts/test.sh` 성공. Newdok-Workspace의 xcresult summary는 totalTestCount 150, failedTests 0, result Passed다. SharedTests는 직전 단독 성공 결과를 Tuist가 재사용했다.
- `fastlane build`는 기존 before_all의 작업 디렉터리 처리 때문에 실제 저장소가 아닌 `/Users/minjae/Desktop/Newdok.xcworkspace`를 찾아 컴파일 전에 실패했다. Fastfile·서명·인증서는 변경하지 않았다.
- 대체 컴파일 검증: `xcodebuild -workspace Newdok.xcworkspace -scheme Newdok -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build` 성공. 기기용 archive·배포 성공을 뜻하지 않는다.
- `git diff --check`, 테스트 하네스 스크립트 검증, CodeGraph 누락·중복 검증 통과. 기존 위젯·성능 비교 스펙 등 사용자 소스는 보존했다. Tuist가 재생성한 프로젝트·scheme는 소스 변경으로 취급하지 않는다.
- UI 수동 조작·실서버 조회·실기기 성능 측정은 수행하지 않았으며 속도 개선 수치를 주장하지 않는다.

## 일반 generate 이후 빌드 실패 재현 및 수정

- 전역 Homebrew Tuist 4.169.1과 mise의 프로젝트 고정 버전 4.143.0이 달랐다. 4.169.1은 외부 static framework의 리소스를 별도 번들로 만들면서 원래 패키지의 deployment target(iOS 12)을 사용했다. 이 번들은 기존 source targetSettings의 iOS 18 설정을 상속하지 않아 Xcode 27에서 Debug 빌드 오류 13개가 발생했다.
- 생성된 pbxproj·SDK·서명·앱 최소 버전은 직접 수정하지 않았다. `~/.zshenv`에서 `tuist` 명령만 `mise exec -- tuist`로 연결해 프로젝트가 선언한 버전을 따르게 했다. 다른 도구의 PATH나 설치 버전은 변경하지 않았다.
- 일반 셸과 새 로그인 셸 모두 `tuist version`이 4.143.0임을 확인했다. `.swift-version`은 계속 Xcode의 Swift를 선택한다.
- 환경변수 접두사 없이 `tuist generate --no-open` 직후 `Newdok` 스킴의 Debug·Release iOS Simulator 빌드가 모두 `BUILD SUCCEEDED`로 완료됐다. 두 빌드는 서명 없이 검증했으며 기기용 archive·배포 검증은 아니다.
