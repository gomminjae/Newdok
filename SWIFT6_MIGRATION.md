# Swift 6 Migration TODO

브랜치: `chore/swift6-migration`
현재 상태: 워닝 235 → **6** (Swift 코드, 97% 해소). 빌드 통과, 에러 0.

## 완료된 작업

| Commit | 내용 |
|---|---|
| `a8faecd` | deployment target iOS 17 → 18 |
| `f9e1c07` | Repository/모델의 `@unchecked Sendable` 제거 |
| `f285f54` | `UserInfo` 도메인 모델에서 `Codable` 분리 |
| `4345c15` | UIKit MainActor isolation 정리 |
| `c11db86` | `Logger` immutable 설계로 전환 |
| `026cea8` | `TokenStorage` 재설계 및 Sendable 적합 일괄 정리 |
| `aab4071` | 동시성 잔여 정리 (NetworkStatusManager, actor init) |
| `e074429` | 잔여 워닝 정리 (deprecated API, dead code) |
| `13e8727` | Merge develop into chore/swift6-migration |
| `b98fae4` | develop 머지 후 빌드 실패 해소 (UserInfo var 환원, UserInfoStoreProtocol: Sendable) |
| `7028f40` | TokenStorage/SelectableItemStore protocol 격리·Sendable 정리 |
| `5d26041` | SubscribeRow 이미지 로드 실패 분기 처리 |
| `4a34dd4` `eb079b8` | Edit*View 토스트 분기 단일 Task로 정리 (region-isolation 우회) |

## 남은 작업

### 1. `ArticleHighlight` `#Predicate` KeyPath Sendable (~6 warnings)

**위치**:
- `Modules/Shared/Sources/Highlight/HighlightModel.swift:117, 124`
- `Modules/Features/Home/Sources/Home/ArticleRow.swift:21` (매크로 확장 워닝)
- `HighlightModel.swift` 내부 `#Predicate` 매크로 확장 워닝

**원인**: SwiftData `@Model` 클래스 `ArticleHighlight`의 `ReferenceWritableKeyPath`가 `#Predicate` 매크로 내부에서 사용. KeyPath가 Sendable 미충족.

`@Model`은 본질적으로 `ModelContext` actor에 묶인 reference type이라 Apple이 의도적으로 Sendable 미선언. 사용자가 추가로 Sendable 선언할 수 있는 위치도 없음 (매크로 합성 코드, KeyPath 자체는 표준 라이브러리).

**런타임 안전성**: 우리 `@Query` 사용은 SwiftUI View body(`@MainActor`) 안에서만 일어남 → ModelContext 격리 유지 → race condition 없음.

**처리 방안**:
- **Swift 6 모드 활성화 직전에** `@preconcurrency import SwiftData` 일괄 추가 (가장 작은 변경)
- 또는 Apple이 SwiftData에 isolation marker 추가하길 대기
- 또는 `FetchDescriptor`/`#Predicate` 대신 fetch 후 메모리 filter로 우회 (성능 손해)

### 2. Swift 6 언어 모드 활성화 (Phase 7)

남은 워닝 0 도달 (또는 `@preconcurrency`로 묵음 처리) 후:

**순서** (의존성 leaf → root):
1. `Shared` → `Core` → `DesignSystem`
2. 각 Feature의 `Interface` → `Domain` → `Data` → 본체
3. `AppCoordinator` → `App` (이미 적용됨)

**방법**: `Tuist/ProjectDescriptionHelpers/ProjectHelper.swift`의 `baseSettings`/`featureSettings`에 `SWIFT_VERSION = "6.0"` 추가.

**주의**: 모드 활성화 시 워닝이 에러로 승격. `#Predicate` KeyPath 6건은 위 1번 항목 처리(보통 `@preconcurrency`) 필요.

## 우리 책임 외 잔여

- `*.xcodeproj: DEFINES_MODULE was set, but no umbrella header` × 9 — Tuist 자동 생성. Tuist의 staticFramework 기본 설정 이슈. 별도 조사 필요하지만 우선순위 낮음.
- `App/Resources/Assets.xcassets` × 1 — 자산 메타.

## 참고

- 코드베이스 위치: `/Users/minjae/Minjae/Newdok`
- Tuist 사용: `tuist install && tuist generate --no-open`
- 빌드 명령: `xcodebuild -workspace Newdok.xcworkspace -scheme Newdok -destination 'generic/platform=iOS Simulator' -configuration Debug build`
- develop 머지 시점 워닝 카운트: 235 → 33 (Swift 코드 6) → Phase 7 모드 활성화 직전 작업만 남음
