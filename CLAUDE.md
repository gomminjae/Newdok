# Newdok

iOS 뉴스레터 앱. SwiftUI + Tuist로 생성되는 모듈러 워크스페이스.

## Build & Run

- 툴체인은 mise로 고정: `tuist` 4.143.0 (없으면 `mise install`).
- **프로젝트 생성** — 신규 클론 후, 그리고 `Project.swift`/의존성을 바꿀 때마다 필수:
  ```
  tuist install && tuist generate --no-open
  ```
- 워크스페이스 `Newdok.xcworkspace`, 스킴 `Newdok` (타깃 `App`, run = Debug).
- CI 빌드만: `bundle exec fastlane build`.
- **`*.xcodeproj/project.pbxproj`는 절대 손으로 수정하지 말 것** — Tuist 생성물이다. 해당 모듈의 `Project.swift`를 고치고 `tuist generate`를 다시 돌린다. (이 파일의 서명/버전 diff는 Xcode가 만드는 노이즈이므로 커밋 대상 아님.)

## Deploy (fastlane)

- `fastlane dev` → 테섭 TestFlight (`com.newdok.test`, Debug)
- `fastlane release` → 상용 TestFlight (`com.newdok.app`, Release)
- `fastlane certs` → match 인증서/프로파일 동기화

## Architecture

- Tuist 워크스페이스 `Newdok.xcworkspace`, `Modules/` 아래 15개 프로젝트 (`Workspace.swift`).
- 인프라 모듈: `NetworkKit`, `DesignSystem`, `Shared`, `DatabaseKit`, `FoundationKit`.
- 피처 모듈(Interface/Implementation 분리): `Auth`, `Home`, `Launch`, `Mypage`, `Explore`, `Bookmark`, `Search`, `Subscribe`, `Detail`. `App`은 각 피처의 Interface + Implementation에 의존.
- 의존성 헬퍼: `Tuist/ProjectDescriptionHelpers/ProjectHelper.swift` (`.feature()`, `.featureInterface()`, `.designSystem` 등). 새 모듈은 `Tuist/Templates/module/` 스캐폴드 사용.
- Swift 6.0, strict concurrency. 배포 타깃/조직명 등은 `ProjectConfig`에서.

## Conventions

- **MVVM**: 비즈니스/관찰 상태는 View 로컬 `@State`가 아니라 ViewModel(`@Observable`)에 둔다 — 키스트로크 재렌더링 churn 방지.
- **Auth**: 소셜 로그인(Apple/Kakao)만. 이메일 로그인은 제거됨.
- **브랜치**: base/default = `develop`. develop에서 분기하고 PR도 develop 대상.
- **커밋**: `type(scope): 제목` (한국어 본문). feat/refactor/perf/fix/chore.

## Notes

- 테스트 타깃 미구성 — 테스트 스킴이 생기면 명령을 여기에 추가할 것.
- 생성물/시크릿은 gitignore: `.omc/`(에이전트 상태), `Modules/App/Derived/`, `Configurations/*.xcconfig`·`Modules/App/Configs/*.xcconfig`(시크릿).
