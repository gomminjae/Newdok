# MFA Step 3: Feature Vertical Slice -- Eliminate Shared Domain & Data

**Date:** 2026-03-27
**Complexity:** HIGH
**Scope:** 8 features x (Domain + Data) new targets, 2 modules deleted, all Project.swift rewritten, AppDIContainer rewritten

---

## Context

Currently the app has a shared `Domain` module (27 entity files, 4 repository protocols, 14 UseCase protocols/impls) and a shared `Data` module (4 RepositoryImpl, 28 DTO files). Every feature depends on `Domain` which couples all features to each other indirectly.

The goal is to make each feature a **complete vertical slice** with its own Domain and Data sub-targets, then delete the shared Domain and Data modules entirely.

---

## Guardrails

### Must Have
- Each feature compiles independently with its own Domain + Data targets
- No feature imports another feature's Domain or Data
- `tuist generate` succeeds with zero errors after completion
- App builds and runs identically to before
- Feature/Sources depends ONLY on Feature/Domain (not Core)
- Feature/Data depends on Feature/Domain + Core

### Must NOT Have
- NO shared Domain module remaining
- NO shared Data module remaining
- NO cross-feature domain model dependencies
- NO breaking changes to Interface protocols (ViewFactory contracts stay the same)
- NO changes to Core module (API enums, NetworkProvider stay as-is)

---

## Execution Order

The work is ordered feature-by-feature so the project compiles after each feature is migrated. A temporary "bridge" approach is used: new feature Domain/Data targets are created alongside the existing shared modules, features are migrated one at a time, and only after ALL features are done are the shared modules deleted.

---

## Step 0: Preparation -- Create Tuist Helper (Optional but Recommended)

No code change. Just understand the pattern each feature will follow:

Each feature's `Project.swift` will go from 2-3 targets to 4-5 targets:
```
FeatureInterface  (existing, unchanged)
FeatureDomain     (NEW -- staticFramework, sources: "Domain/Sources/**")
FeatureData       (NEW -- staticFramework, sources: "Data/Sources/**", depends on FeatureDomain + Core)
Feature           (existing, change dep: Domain -> FeatureDomain)
FeatureTests      (existing if present, change dep: Domain -> FeatureDomain)
```

**Acceptance:** No code changes, just understanding confirmed.

---

## Step 1: Auth Feature -- First Vertical Slice (PILOT)

Auth is the best pilot because it has the most self-contained user-related flows and already has UseCase impls in Sources/UseCase/.

### 1a. Create directory structure

```
Modules/Features/Auth/Domain/Sources/
Modules/Features/Auth/Data/Sources/
```

### 1b. Create Auth Domain files

**File: `Modules/Features/Auth/Domain/Sources/AuthRepository.swift`**
```swift
import Foundation

public protocol AuthRepository {
    func login(loginId: String, password: String) async throws -> (AuthUser, String)
    func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async throws -> AuthSignupResponse
    func checkPhoneNumber(_ phoneNumber: String) async throws -> [AuthSimpleUser]
    func checkIDDup(_ loginId: String) async throws -> AuthCheckResult<AuthSimpleUser>
    func authSMS(phoneNumber: String) async throws -> AuthSMSResponse
    func preInvestigate(industryId: String, interestIds: [String]) async throws -> [AuthRecommendedBrand]
}
```

**File: `Modules/Features/Auth/Domain/Sources/Models/AuthUser.swift`**
Context-specific model -- only the fields Auth actually needs:
```swift
public struct AuthUser {
    public let id: Int
    public let loginId: String
    public let phoneNumber: String
    public let subscribeEmail: String?
    public let nickname: String
    public let birthYear: String
    public let gender: String
    public let createdAt: String
    public let industryId: Int?
    public let interestIds: [Int]  // Auth only needs IDs, not full Interest objects

    public init(id: Int, loginId: String, phoneNumber: String, subscribeEmail: String?,
                nickname: String, birthYear: String, gender: String, createdAt: String,
                industryId: Int?, interestIds: [Int]) { ... }
}
```

**File: `Modules/Features/Auth/Domain/Sources/Models/AuthSignupResponse.swift`**
```swift
public struct AuthSignupResponse {
    public let user: AuthUser
    public let accessToken: String
    public init(user: AuthUser, accessToken: String) { ... }
}
```

**File: `Modules/Features/Auth/Domain/Sources/Models/AuthSimpleUser.swift`**
```swift
public struct AuthSimpleUser: Identifiable {
    public let id: Int
    public let loginId: String
    public let phoneNumber: String
    public let createdAt: String
    public var maskedLoginId: String { ... }
    public var formattedCreatedAt: String { ... }
    public init(...) { ... }
}
```

**File: `Modules/Features/Auth/Domain/Sources/Models/AuthSMSResponse.swift`**
```swift
public struct AuthSMSResponse {
    public let code: Int
    public init(code: Int) { ... }
}
```

**File: `Modules/Features/Auth/Domain/Sources/Models/AuthRecommendedBrand.swift`**
```swift
public struct AuthInterest: Identifiable {
    public let id: Int
    public let name: String
    public init(id: Int, name: String) { ... }
}

public struct AuthRecommendedBrand {
    public let id: Int
    public let name: String
    public let description: String
    public let cycle: String
    public let subscribeUrl: String
    public let imageUrl: String
    public let interests: [AuthInterest]
    public init(...) { ... }
}
```

**File: `Modules/Features/Auth/Domain/Sources/Models/AuthCheckResult.swift`**
```swift
public enum AuthCheckResult<T> {
    case exists(T)
    case notFound
}
```

**File: `Modules/Features/Auth/Domain/Sources/Models/AuthError.swift`**
```swift
import Shared

public enum LoginError: Error {
    case invalidPassword
    case accountNotFound
    case networkError(Error)
}

extension LoginError: AppErrorConvertible {
    public func toAppError() -> AppError { ... }
}
```

**File: `Modules/Features/Auth/Domain/Sources/LoginUseCase.swift`**
```swift
public protocol LoginUseCase {
    func execute(loginId: String, password: String) async throws -> AuthUser
}
```

**File: `Modules/Features/Auth/Domain/Sources/SignupUseCase.swift`**
```swift
public struct AuthSignupRequest {
    public let loginId: String
    public let password: String
    public let phoneNumber: String
    public let nickname: String
    public let birthYear: String
    public let gender: String
    public init(...) { ... }
}

public protocol SignupUseCase {
    func execute(request: AuthSignupRequest) async throws -> AuthUser
}
```

### 1c. Create Auth Data files

**File: `Modules/Features/Auth/Data/Sources/AuthRepositoryImpl.swift`**
- Copy from `Modules/Data/Sources/Repository/UserRepositoryImpl.swift`
- Keep ONLY the auth-related methods: login, signup, checkPhoneNumber, checkIDDup, authSMS, preInvestigate
- Change `import Domain` to `import AuthDomain`
- Change all Domain types to Auth-prefixed types (User -> AuthUser, etc.)
- DTOs map to Auth domain models via `toAuthDomain()` methods

**File: `Modules/Features/Auth/Data/Sources/DTO/LoginResponseDTO.swift`**
- Copy from `Modules/Data/Sources/DTO/User/LoginResponseDTO.swift`
- Change `toDomain()` to map to `AuthUser` instead of `Domain.User`

**File: `Modules/Features/Auth/Data/Sources/DTO/SignupResponseDTO.swift`**
- Copy from `Modules/Data/Sources/DTO/User/SignupResponseDTO.swift`

**File: `Modules/Features/Auth/Data/Sources/DTO/SimpleUserDTO.swift`**
- Copy from `Modules/Data/Sources/DTO/User/SimpleUserDTO.swift`

**File: `Modules/Features/Auth/Data/Sources/DTO/SMSResponseDTO.swift`**
- Copy from `Modules/Data/Sources/DTO/User/SMSResponseDTO.swift`

**File: `Modules/Features/Auth/Data/Sources/DTO/UserDTO.swift`**
- Copy from `Modules/Data/Sources/DTO/User/UserDTO.swift`
- Change `toDomain()` to return `AuthUser`

**File: `Modules/Features/Auth/Data/Sources/DTO/BrandListResponseDTO.swift`**
- Copy from `Modules/Data/Sources/DTO/User/BrandListResponseDTO.swift`

**File: `Modules/Features/Auth/Data/Sources/DTO/ErrorResponseDTO.swift`**
- Copy from `Modules/Data/Sources/DTO/User/Error/ErrorResponseDTO.swift`

### 1d. Update Auth/Project.swift

```swift
import ProjectDescription

let project = Project(
    name: "Auth",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "AuthInterface",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.auth.interface",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Interface/Sources/**"],
            settings: .settings(base: ["SKIP_INSTALL": "YES", "SWIFT_STRICT_CONCURRENCY": "complete"])
        ),
        .target(
            name: "AuthDomain",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.auth.domain",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Domain/Sources/**"],
            dependencies: [
                .project(target: "Shared", path: "../../Shared")
            ],
            settings: .settings(base: ["SKIP_INSTALL": "YES", "SWIFT_STRICT_CONCURRENCY": "complete"])
        ),
        .target(
            name: "AuthData",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.auth.data",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Data/Sources/**"],
            dependencies: [
                .target(name: "AuthDomain"),
                .project(target: "Core", path: "../../Core")
            ],
            settings: .settings(base: ["SKIP_INSTALL": "YES", "SWIFT_STRICT_CONCURRENCY": "complete"])
        ),
        .target(
            name: "Auth",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.auth",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "AuthInterface"),
                .target(name: "AuthDomain"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Shared", path: "../../Shared")
            ],
            settings: .settings(base: ["SKIP_INSTALL": "YES", "SWIFT_STRICT_CONCURRENCY": "complete"])
        ),
        .target(
            name: "AuthTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.newdok.auth.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Auth"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Shared", path: "../../Shared")
            ]
        )
    ]
)
```

### 1e. Update Auth/Sources files

- `LoginUseCaseImpl.swift`: Change `import Domain` to `import AuthDomain`. Change `User` to `AuthUser`.
- `SignupUseCaseImpl.swift`: Same import change, type changes.
- All ViewModels/Views that reference `Domain.User`, `Domain.LoginError` etc: Change to `AuthDomain.AuthUser`, `AuthDomain.LoginError`.

### 1f. Update AppDIContainer for Auth

Replace the Auth-related registrations:
```swift
// Old: container.register(UserRepository.self) { ... }
// New:
import AuthDomain
import AuthData

container.register(AuthRepository.self) { r in
    let provider = r.resolve(MoyaProvider<UserAPI>.self)!
    return AuthRepositoryImpl(provider: provider)
}.inObjectScope(.container)

container.register(LoginUseCase.self) { r in
    let repo = r.resolve(AuthRepository.self)!
    // LoginUseCaseImpl still lives in Auth/Sources/UseCase/
    // But AppDIContainer needs access -- see note below
}
```

**IMPORTANT NOTE:** Since `LoginUseCaseImpl` lives inside the `Auth` target (not `AuthData`), and AppCoordinator currently does NOT depend on concrete Feature targets (only Interfaces), the DI registration pattern needs adjustment. Options:

**Option A (Recommended):** Move UseCase registration into a factory method exposed via `AuthInterface`. Add a static registration method to `AuthViewFactory` that accepts the container. AppCoordinator calls `AuthViewFactory.registerDependencies(container)`.

**Option B:** AppCoordinator adds dependency on `AuthData` (not full `Auth`), and UseCase impls move to `AuthData`.

For this plan we use **Option A** -- each feature's Interface exposes a `register(container:)` method.

### 1g. Verify Auth compiles

Run `tuist generate` and build Auth target in isolation.

**Acceptance Criteria:**
- `AuthDomain` target compiles with 0 errors
- `AuthData` target compiles with 0 errors
- `Auth` target compiles with 0 errors
- Auth feature has NO `import Domain` or `import Data` statements
- Login/Signup flows work identically

---

## Step 2: Home Feature

### 2a. Create directory structure
```
Modules/Features/Home/Domain/Sources/
Modules/Features/Home/Data/Sources/
```

### 2b. Home Domain files

**`Home/Domain/Sources/HomeRepository.swift`**
```swift
public protocol HomeArticleRepository {
    func fetchArticles(year: String, publicationMonth: String) async throws -> [HomeArticles]
    func fetchDayArticles(year: String, publicationMonth: String, publicationDate: String) async throws -> [HomeArticle]
    func fetchTodayArticles() async throws -> [HomeArticle]
    func refresh() async throws
}

public protocol HomeNewsletterRepository {
    func fetchActiveSubscription() async throws -> [HomeNewsletter]
}
```

**`Home/Domain/Sources/Models/HomeArticle.swift`**
```swift
public struct HomeArticle: Identifiable {
    public var id: String { "article-\(articleId)" }
    public let brandName: String
    public let imageUrl: String
    public let articleTitle: String
    public let articleId: Int
    public let status: String
    public let publishDate: Int?
    public init(...) { ... }
}
```

**`Home/Domain/Sources/Models/HomeArticles.swift`** (calendar day summary)
```swift
public struct HomeArticles {
    public let publishDate: Int
    public let hasArticles: Bool
    public let totalCount: Int
    public var unreadCount: Int
    public init(...) { ... }
}
```

**`Home/Domain/Sources/Models/HomeNewsletter.swift`**
```swift
public struct HomeNewsletter {
    public let id: Int?
    public let brandName: String
    public let imageUrl: String
    public let publicationCycle: String?
    public init(...) { ... }
}
```

**`Home/Domain/Sources/Models/HomeData.swift`**
```swift
public struct HomeData {
    public let articles: [HomeArticle]
    public let activeNewsletters: [HomeNewsletter]
    public init(...) { ... }
}
```

**`Home/Domain/Sources/Models/HomeSnapshot.swift`** -- move from Domain/Sources/UseCase/Home/HomeBusinessUseCase.swift

**`Home/Domain/Sources/FetchHomeDataUseCase.swift`**
```swift
public protocol FetchHomeDataUseCase {
    func fetchTodayData() async throws -> HomeData
    func fetchMonthlyData(year: String, month: String) async throws -> [HomeArticles]
    func fetchDayArticles(year: String, month: String, day: String) async throws -> [HomeArticle]
    func decorateTodayArticles(_ articles: [HomeArticle], readArticleIds: Set<Int>) -> [HomeArticle]
    func unreadCount(in articles: [HomeArticle]) -> Int
    func refresh() async throws
}
```

**`Home/Domain/Sources/HomeBusinessUseCase.swift`**
```swift
public protocol HomeBusinessUseCase: AnyObject {
    func snapshot() async -> HomeSnapshot
    func loadToday() async -> HomeSnapshot
    // ... (same protocol, but using Home-prefixed types)
}
```

### 2c. Home Data files

**`Home/Data/Sources/HomeArticleRepositoryImpl.swift`**
- Subset of ArticleRepositoryImpl: fetchArticles, fetchDayArticles, fetchTodayArticles, refresh
- Maps DTOs to `HomeArticle` / `HomeArticles`

**`Home/Data/Sources/HomeNewsletterRepositoryImpl.swift`**
- Subset of NewsletterRepositoryImpl: fetchActiveSubscription only
- Maps NewsletterDTO to `HomeNewsletter`

**`Home/Data/Sources/DTO/`** -- Copy only needed DTOs:
- ArticlesResponseDTO.swift, ArticlesDTO.swift, ArticleDTO.swift
- NewsletterDTO.swift (just the subscription DTO)

### 2d. Update Home/Project.swift
Same pattern as Auth: add `HomeDomain` and `HomeData` targets.

### 2e. Update Home/Sources files
- `FetchHomeDataUseCaseImpl.swift`: Change `import Domain` to `import HomeDomain`
- `DefaultHomeBusinessUseCase.swift`: Same
- All Views/ViewModels: Update type references

### 2f. Verify Home compiles

**Acceptance Criteria:**
- `HomeDomain`, `HomeData`, `Home` targets compile with 0 errors
- Home feature has NO `import Domain` or `import Data` statements
- Home feed displays correctly

---

## Step 3: Remaining 6 Features (Same Pattern)

Apply the identical pattern to each feature. Below is the **exact Domain/Data content** for each:

### 3a. MyPage

**MyPageDomain models:** `MyPageUser` (full profile), `MyPageNicknameResponse`, `MyPageProfileError`
**MyPageDomain protocols:** `MyPageUserRepository` (getProfile, updateNickname, updatePassword, updateInterest, updateIndustry, updatePhoneNumber, withdraw), `MyPageStatsRepository` (fetchReceivedArticleCount, fetchSubscriptionCount)
**MyPageDomain UseCases:** `ProfileUseCase` protocol (move from Domain)
**MyPageData:** `MyPageUserRepositoryImpl` (subset of UserRepositoryImpl), `MyPageStatsRepositoryImpl` (fetches counts from ArticleAPI + NewsletterAPI)
**MyPageData DTOs:** UserDTO, NicknameResponseDTO, ArticlesCountDTO, NewslettersCountDTO

### 3b. Explore

**ExploreDomain models:** `ExploreBrand`, `ExploreBrandDetail`, `ExploreNewsletterDetail`, `ExploreRecommendedNewsletter`, `ExploreOption`, `ExploreOptionList`, `ExploreIndustry`, `ExploreInterest`
**ExploreDomain protocols:** `ExploreNewsletterRepository` (fetchNewsletters, fetchNewsletterBrand, fetchGuestAllNewsletters, fetchGuestNewsletterBrand, fetchRecommendation, fetchOptionList)
**ExploreDomain UseCases:** `NewsletterUseCase` protocol (explore-specific subset), `LoadOptionsUseCase` protocol + impl
**ExploreData:** `ExploreNewsletterRepositoryImpl` (subset of NewsletterRepositoryImpl)
**ExploreData DTOs:** BrandDTO, BrandDetailDTO, NewsletterDetailDTO, RecommendedNewsletterDTO, OptionDTO, IndustryDTO

### 3c. Detail

**DetailDomain models:** `DetailArticleDetail`, `DetailBrandDetail`, `DetailBrandArticle`, `DetailInterest`
**DetailDomain protocols:** `DetailArticleRepository` (fetchArticleDetail), `DetailBrandRepository` (fetchNewsletterBrand/fetchGuestNewsletterBrand, pauseSubscription, resumeSubscription)
**DetailDomain UseCases:** `ArticleDetailUseCase` protocol (move from Domain)
**DetailData:** `DetailArticleRepositoryImpl`, `DetailBrandRepositoryImpl`
**DetailData DTOs:** ArticleDetailDTO, BrandDetailDTO, BrandArticleDTO

### 3d. Bookmark

**BookmarkDomain models:** `BookmarkArticle`, `BookmarkedArticles`, `MonthlyBookmark`, `Bookmark`, `BookmarkInterest`
**BookmarkDomain protocols:** `BookmarkRepository` (fetchBookmarkArticles, changeBookmarkState, fetchBookmarkedInterest)
**BookmarkDomain UseCases:** `ArticleUseCase` protocol (bookmark-specific subset)
**BookmarkData:** `BookmarkRepositoryImpl` (subset of ArticleRepositoryImpl)
**BookmarkData DTOs:** BookmarkDTO, BookmarkedArticleDTO, MonthlyBookmarkDTO, InterestDTO

### 3e. Search

**SearchDomain models:** `SearchedNewsletter`, `PopularKeyword`, `PopularKeywordList`
**SearchDomain protocols:** `SearchRepository` (searchNewsletters, fetchPopularKeywords)
**SearchDomain UseCases:** `SearchUseCase` protocol (move from Domain)
**SearchData:** `SearchRepositoryImpl` (copy existing)
**SearchData DTOs:** SearchedNewsletterDTO, PopularKeywordDTO, SearchQueryDTO

### 3f. Subscribe

**SubscribeDomain models:** `SubscribeNewsletter`, `SubscribeNewslettersCount`
**SubscribeDomain protocols:** `SubscribeNewsletterRepository` (fetchActiveSubscription, fetchPausedSubscription, pauseSubscription, resumeSubscription, fetchSubscriptionCount)
**SubscribeDomain UseCases:** `NewsletterUseCase` protocol (subscribe-specific subset)
**SubscribeData:** `SubscribeNewsletterRepositoryImpl` (subset of NewsletterRepositoryImpl)
**SubscribeData DTOs:** NewsletterDTO, NewslettersCountDTO

**Acceptance Criteria for each feature:**
- FeatureDomain, FeatureData, Feature targets compile with 0 errors
- Feature has NO `import Domain` or `import Data` statements
- Feature's existing functionality works identically

---

## Step 4: Update AppCoordinator and AppDIContainer

### 4a. Update AppCoordinator/Project.swift dependencies

Remove:
```swift
.project(target: "Data", path: "../Data"),
.project(target: "Domain", path: "../Domain"),
```

Add (for each feature that needs DI wiring):
```swift
.project(target: "AuthDomain", path: "../Features/Auth"),
.project(target: "AuthData", path: "../Features/Auth"),
.project(target: "HomeDomain", path: "../Features/Home"),
.project(target: "HomeData", path: "../Features/Home"),
.project(target: "MypageDomain", path: "../Features/MyPage"),
.project(target: "MypageData", path: "../Features/MyPage"),
.project(target: "ExploreDomain", path: "../Features/Explore"),
.project(target: "ExploreData", path: "../Features/Explore"),
.project(target: "DetailDomain", path: "../Features/Detail"),
.project(target: "DetailData", path: "../Features/Detail"),
.project(target: "BookmarkDomain", path: "../Features/Bookmark"),
.project(target: "BookmarkData", path: "../Features/Bookmark"),
.project(target: "SearchDomain", path: "../Features/Search"),
.project(target: "SearchData", path: "../Features/Search"),
.project(target: "SubscribeDomain", path: "../Features/Subscribe"),
.project(target: "SubscribeData", path: "../Features/Subscribe"),
```

### 4b. Rewrite AppDIContainer.swift

Replace ALL repository and UseCase registrations. Each registration now uses the feature-specific types:

```swift
import AuthDomain; import AuthData
import HomeDomain; import HomeData
import MypageDomain; import MypageData
import ExploreDomain; import ExploreData
import DetailDomain; import DetailData
import BookmarkDomain; import BookmarkData
import SearchDomain; import SearchData
import SubscribeDomain; import SubscribeData

// Network stays the same (Core)
// MoyaProvider registrations stay the same (Core)

// Auth
container.register(AuthRepository.self) { r in
    AuthRepositoryImpl(provider: r.resolve(MoyaProvider<UserAPI>.self)!)
}.inObjectScope(.container)

// Home
container.register(HomeArticleRepository.self) { r in
    HomeArticleRepositoryImpl(provider: r.resolve(MoyaProvider<ArticleAPI>.self)!)
}.inObjectScope(.container)

container.register(HomeNewsletterRepository.self) { r in
    HomeNewsletterRepositoryImpl(provider: r.resolve(MoyaProvider<NewsletterAPI>.self)!)
}.inObjectScope(.container)

// ... same pattern for all features
```

### 4c. Update App/Project.swift dependencies

Remove:
```swift
.project(target: "Domain", path: "../Domain"),
```

Add for each feature:
```swift
.project(target: "AuthDomain", path: "../Features/Auth"),
.project(target: "AuthData", path: "../Features/Auth"),
// ... etc for all features
```

**Acceptance Criteria:**
- AppCoordinator compiles with 0 `import Domain` or `import Data`
- App target compiles with 0 errors
- All DI registrations resolve correctly at runtime

---

## Step 5: Delete Shared Domain and Data Modules

### 5a. Remove from Workspace.swift

Remove these lines:
```swift
"Modules/Domain",
"Modules/Data",
```

### 5b. Delete directories

```bash
rm -rf Modules/Domain
rm -rf Modules/Data
```

### 5c. Remove Domain/Data references from ALL Project.swift files

Grep for any remaining `.project(target: "Domain"` or `.project(target: "Data"` references across all Project.swift files and remove them.

### 5d. Clean up Launch and Survey

- **Launch:** Already does NOT depend on Domain. No changes needed.
- **Survey:** Already depends only on Core. No changes needed.

### 5e. Final verification

```bash
tuist generate
# Build the App scheme
xcodebuild -workspace Newdok.xcworkspace -scheme Newdok -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build
```

**Acceptance Criteria:**
- `Modules/Domain/` directory does not exist
- `Modules/Data/` directory does not exist
- `tuist generate` succeeds
- Full app build succeeds with 0 errors
- All 10 features work correctly at runtime
- No Swift file in the project contains `import Domain` or `import Data` (only feature-specific imports like `import AuthDomain`, `import HomeData`, etc.)

---

## Step 6: Handle the 3 UseCaseImpls Currently in Domain

These must be distributed DURING Steps 1-3 (not after):

| UseCaseImpl | Current Location | Target Feature | Rationale |
|---|---|---|---|
| `UserUseCaseImpl` | Domain/Sources/UseCase/User/ | **Split: Auth gets login/signup/check methods, MyPage gets profile/update methods** | UserUseCaseImpl is a god-object. Split into feature-specific UseCases. Auth already has LoginUseCaseImpl/SignupUseCaseImpl that wrap it. After migration, Auth's LoginUseCaseImpl should directly call AuthRepository instead of going through UserUseCase. |
| `ArticleUseCaseImpl` | Domain/Sources/UseCase/Article/ | **Split: Home gets fetch methods, Bookmark gets bookmark methods, Detail gets detail method** | Same reasoning -- split by feature context. |
| `NewsletterUseCaseImpl` | Domain/Sources/UseCase/Newsletter/ | **Split: Explore gets browse/filter methods, Subscribe gets subscription methods, Home gets fetchActive, Detail gets brand methods** | Same reasoning. |

**Key insight:** After splitting, these "god UseCases" disappear entirely. Each feature defines only the UseCase protocol methods it actually needs, and the impl in that feature calls its own repository directly. The current indirection (LoginUseCaseImpl -> UserUseCase -> UserRepository) becomes (LoginUseCaseImpl -> AuthRepository) -- simpler and more direct.

**Acceptance Criteria:**
- No `UserUseCaseImpl`, `ArticleUseCaseImpl`, or `NewsletterUseCaseImpl` exist anywhere
- Each feature has its own focused UseCase impls
- `LoadOptionsUseCaseImpl` moves to Explore (it fetches option lists)

---

## File Count Estimates

| Feature | New Domain Files | New Data Files | Modified Existing Files |
|---|---|---|---|
| Auth | ~10 (1 repo protocol, 6 models, 2 UseCase protocols, 1 error) | ~8 (1 impl, 7 DTOs) | ~8 (Project.swift, 2 UseCaseImpls, ~5 Views/VMs) |
| Home | ~7 (2 repo protocols, 3 models, 2 UseCase protocols) | ~5 (2 impls, 3 DTOs) | ~6 (Project.swift, 2 UseCaseImpls, ~3 Views/VMs) |
| MyPage | ~5 (2 repo protocols, 2 models, 1 UseCase protocol) | ~5 (2 impls, 3 DTOs) | ~6 (Project.swift, 1 UseCaseImpl, ~4 Views/VMs) |
| Explore | ~9 (1 repo protocol, 7 models, 1 UseCase protocol) | ~7 (1 impl, 6 DTOs) | ~5 (Project.swift, ~4 Views/VMs) |
| Detail | ~6 (2 repo protocols, 3 models, 1 UseCase protocol) | ~4 (2 impls, 2 DTOs) | ~5 (Project.swift, 1 UseCaseImpl, ~3 Views/VMs) |
| Bookmark | ~6 (1 repo protocol, 4 models, 1 UseCase protocol) | ~4 (1 impl, 3 DTOs) | ~4 (Project.swift, ~3 Views/VMs) |
| Search | ~4 (1 repo protocol, 2 models, 1 UseCase protocol) | ~4 (1 impl, 3 DTOs) | ~4 (Project.swift, 1 UseCaseImpl, ~2 Views/VMs) |
| Subscribe | ~4 (1 repo protocol, 2 models, 1 UseCase protocol) | ~3 (1 impl, 2 DTOs) | ~4 (Project.swift, ~3 Views/VMs) |
| AppCoordinator | 0 | 0 | 2 (Project.swift, AppDIContainer.swift) |
| App | 0 | 0 | 1 (Project.swift) |
| Workspace | 0 | 0 | 1 (Workspace.swift) |
| **Totals** | **~51** | **~40** | **~46** |

---

## Risk Mitigations

1. **Compile after each feature migration** -- never batch more than one feature before verifying build.
2. **Keep shared Domain/Data alive until Step 5** -- other features still compile against them while you migrate one at a time.
3. **Interest type duplication** -- `Interest` is used by many features. Each feature defines its own (AuthInterest, ExploreInterest, etc.). This is intentional -- vertical slices own their models.
4. **DTO duplication** -- Some DTOs (e.g., NewsletterDTO) will exist in multiple feature Data targets. This is acceptable and intended for decoupling.
5. **AppDIContainer grows** -- It will have more registrations, but each is simpler (feature-scoped). This is temporary; future steps can move DI into features.

---

## Success Criteria

- [ ] All 8 data-using features have their own Domain + Data targets
- [ ] NO shared Domain module exists
- [ ] NO shared Data module exists
- [ ] Each feature compiles independently (no cross-feature domain deps)
- [ ] `tuist generate` succeeds
- [ ] Full app builds and runs correctly
- [ ] All 3 god-UseCaseImpls are eliminated and split into feature-specific impls
- [ ] Feature/Sources NEVER imports Core directly (only via Feature/Data)
