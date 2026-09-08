# Newdok

SwiftUI와 Tuist를 사용하는 모듈형 iOS 뉴스레터 앱.

## Toolchain & Build

- mise가 고정한 `tuist` 4.143.0을 사용한다. 도구가 없으면 먼저 `mise install`을 실행한다.
- 신규 클론 또는 `Project.swift`·의존성 변경 후 프로젝트를 다시 생성한다:
  ```sh
  mise exec -- tuist install
  mise exec -- tuist generate --no-open
  ```
- 워크스페이스는 `Newdok.xcworkspace`, 앱 스킴은 `Newdok`다.
- Release 빌드 검증은 `fastlane build`를 사용한다.
- `*.xcodeproj/project.pbxproj`는 Tuist 생성물이므로 직접 수정하거나 생성 diff를 커밋하지 않는다. 변경은 manifest와 helper에서 한다.

## Architecture

- 프로젝트 목록의 기준은 `Workspace.swift`, 공통 타깃 설정과 의존성 shortcut의 기준은 `Tuist/ProjectDescriptionHelpers/ProjectHelper.swift`다.
- 의존 방향은 `App → Feature → Core → External`을 유지하고 순환 의존을 만들지 않는다.
- Core 모듈은 `NetworkKit`, `DesignSystem`, `Shared`, `DatabaseKit`, `FoundationKit`이다.
- TMA Feature는 필요에 따라 `{Feature}Interface`, `{Feature}Domain`, `{Feature}Data`, `{Feature}`, `{Feature}Testing`, `{Feature}Tests`, `{Feature}Example` 타깃으로 구성한다.
- View와 ViewModel은 Domain 프로토콜에 의존한다. Data 구현과 NetworkKit 접근은 Data 또는 Builder/DI 조립 경계에 둔다.
- 새 타깃이나 의존성을 직접 반복 정의하기 전에 `Project.feature`, `Project.module`, `TargetDependency` shortcut을 재사용한다.
- 최소 지원 버전은 iOS 18.0이다. 모든 모듈은 strict concurrency `complete`이며 App 타깃은 Swift 6.0을 명시한다.

## Engineering Principles

- **YAGNI**: 현재 요구사항에 필요한 가장 작은 변경만 구현한다. 가상의 미래 사용처를 위한 abstraction, wrapper, factory, 설정, 의존성을 추가하지 않는다.
- 코드를 추가하기 전에 기존 타입·helper·패턴·표준 라이브러리·플랫폼 API·설치된 의존성을 찾아 재사용한다.
- 공용 코드를 바꾸기 전에 모든 호출부와 실제 데이터 흐름을 확인한다. 증상별 우회보다 가장 좁은 공통 지점의 root cause를 수정한다.
- **Type safety**: 문자열·딕셔너리보다 명시적인 모델과 enum을 사용하고, 신뢰 경계에서 입력을 검증한다. 검증된 불변식 없이 force unwrap, force cast, `try!`를 사용하지 않는다.
- **Runtime/memory/lifetime safety**: 배열 범위, optional, continuation 재개 횟수, 객체 수명을 명시적으로 다룬다. retain cycle과 use-after-lifetime을 피하고 callback capture가 필요하면 소유 관계를 검토한다.
- 데이터 손실 방지, 보안·개인정보, 접근성, 입력 검증을 단순화를 이유로 제거하지 않는다.
- unrelated 변경을 보존하고 요청 범위 밖 파일을 정리하거나 재포맷하지 않는다.

## Swift Concurrency & State

- 비즈니스·관찰 상태는 `@Observable` ViewModel에 두고, 일시적인 표현 상태만 View의 `@State`에 둔다.
- 단발성 비동기 작업은 `async/await`를 기본으로 사용한다. Combine은 지속 스트림이나 Publisher 상호운용이 실제로 필요할 때만 사용한다.
- **Thread/concurrency safety**: UI와 UI-bound 상태 변경은 `@MainActor`로 격리한다. 비동기 공유 상태는 actor를 우선하고, 작은 동기 임계 구역만 `Synchronization.Mutex`로 보호한다. lock을 잡은 채 `await`하지 않는다.
- 경계를 넘는 값은 `Sendable`을 만족시킨다. `@unchecked Sendable`은 동기화 불변식을 코드로 보장하고 근거를 주석으로 남길 때만 사용한다.
- View 생명주기에 묶인 작업은 `.task` 또는 `.task(id:)`로 구조화한다. 불필요한 unstructured `Task`와 `Task.detached`를 만들지 않는다.
- 새 요청이 이전 요청을 대체할 수 있으면 취소를 전파하고, 취소됐거나 오래된 응답이 최신 상태를 덮어쓰지 않게 한다.
- `CancellationError`는 사용자 오류로 표시하지 않는다.
- continuation은 성공·실패·취소의 모든 경로에서 정확히 한 번만 재개되도록 보장한다.
- actor isolation을 피하려고 임의의 lock이나 `nonisolated(unsafe)`를 추가하지 않는다. 컴파일러 경고를 숨기지 말고 소유권과 격리 경계를 수정한다.

## Test Harness

- 전체 테스트: `./scripts/test.sh`
- 모듈 테스트: 해당 `Project.swift` 옆의 `./test.sh` (예: `./Modules/Features/Search/test.sh`)
- macOS CI는 비용 방지를 위해 수동 실행만 하며 로컬과 같은 `./scripts/test.sh`를 호출한다.
- `Tests/`가 있는 모든 모듈은 실행 가능한 `test.sh`를 둔다. 모듈 스크립트는 스킴만 고정하고 공통 로직과 인자를 루트 하네스에 위임한다.
- 새 테스트 타깃은 `Tests/`, 모듈 `test.sh`, 실행 권한을 함께 추가한다. 루트 하네스의 검증을 우회하지 않는다.
- 변경 후 최소 해당 모듈 테스트를 실행한다. `ProjectHelper`, Core 또는 여러 모듈에 걸친 변경은 전체 테스트를 실행한다.
- 단위 테스트는 Swift Testing을 기본으로 사용한다. XCUI 기반 UI 테스트처럼 지원되지 않는 경우에만 XCTest를 사용한다.
- 새로 만들거나 수정하는 비동기 테스트는 실제 네트워크, 임의의 sleep, 실행 순서, 공유 전역 상태에 의존하지 않는다. 필요한 이벤트 순서는 actor나 continuation으로 제어한다.

## Product & Code Conventions

- 로그인 진입점은 Apple·Kakao 소셜 로그인만 지원한다. 별도 승인 없이 ID/비밀번호 로그인을 다시 추가하지 않는다.
- SwiftUI 컨트롤은 보이는 전체 영역이 hit-test 가능해야 한다. 투명하거나 확장된 영역은 크기 지정 뒤 `contentShape`를 적용하고 접근성 label·trait를 보존한다.
- base/default 브랜치와 PR 대상은 `develop`이다.
- 커밋 제목은 `type(scope): 제목` 형식을 사용한다. 주요 type은 `feat`, `fix`, `refactor`, `perf`, `test`, `chore`다.

## Spec-Driven Development

- 새 화면·플로우·모듈처럼 비자명한 기능은 `docs/specs/_template/`를 `docs/specs/<기능>/`으로 복사해 스펙 승인 후 구현한다.
- `spec.md`에는 요구사항과 수용 조건, `plan.md`에는 설계와 영향 범위, `tasks.md`에는 순서 있는 작업을 기록한다.
- 구현과 스펙이 다르면 코드를 맞추기 전에 스펙을 먼저 갱신한다.

## Deploy

- 빌드·테스트 요청은 배포 권한을 포함하지 않는다. TestFlight 업로드, 인증서 변경, 외부 저장소 변경은 사용자가 명시적으로 요청한 경우에만 수행한다.
- 개발 TestFlight: `fastlane dev` (`com.newdok.test`, Debug)
- 상용 TestFlight: `fastlane release` (`com.newdok.app`, Release)
- 동시 배포: `fastlane all`
- 인증서 동기화: `fastlane certs`

## Generated Files & Secrets

- `.omc/`, `build/`, `Tuist/.build/`, Xcode 사용자 데이터와 Tuist가 재생성한 프로젝트·scheme diff는 소스가 아니다.
- `Configurations/*.xcconfig`, `Modules/App/Configs/*.xcconfig`, 인증서와 API 키는 커밋하거나 출력하지 않는다.
- 토큰, cookie, 인증 header, 개인정보, 전체 응답 body를 production log에 남기지 않는다.
- 기존 로컬 xcconfig나 signing 설정을 임의 값으로 덮어쓰지 않는다.
