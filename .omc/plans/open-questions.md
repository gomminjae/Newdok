# Open Questions

## MFA Step 3 Vertical Slice - 2026-03-27

- [ ] **DI Registration Pattern:** Should each feature expose a `registerDependencies(container:)` via its Interface, or should AppCoordinator depend on each FeatureData target directly? The plan recommends Option A (Interface exposes registration), but Option B (AppCoordinator depends on FeatureData) is simpler to implement. -- Affects AppCoordinator coupling and the Interface contract.

- [ ] **`Interest` type is referenced by User, Brand, BrandDetail, RecommendedBrand, NewsletterDetail, Option entities across 6+ features.** Each feature will define its own (AuthInterest, ExploreInterest, etc.). Confirm this duplication is acceptable vs. keeping a tiny shared types module. -- Affects whether a `SharedTypes` micro-module is needed.

- [ ] **`CheckResult<T>` currently lives in Shared module.** Auth uses `CheckResult<SimpleUser>`. After migration it becomes `AuthCheckResult<AuthSimpleUser>`. Should CheckResult stay in Shared (generic utility) or move to Auth (only consumer)? -- Affects Shared module scope.

- [ ] **`LoadOptionsUseCaseImpl` currently in Domain, uses `SelectableItemStore` from Shared.** Plan assigns it to Explore. But it is called at app startup (AppCoordinator/App level), not from Explore UI. Should it stay in AppCoordinator as an infra concern, or move to Explore? -- Affects where startup logic lives.

- [ ] **DTO naming conflicts in Tuist static frameworks:** Multiple features will have types named e.g. `NewsletterDTO`. Since these are in different static framework targets, Swift module namespacing should handle it. Verify that Tuist-generated Xcode projects correctly namespace these. -- Affects whether DTOs need feature prefixes.

- [ ] **`NetworkError` and `ErrorMapper` live in Core.** Some feature Data impls catch `NetworkError` (e.g., AuthRepositoryImpl catches it to throw `LoginError`). Confirm Core stays as the error infra layer and feature Data targets can depend on it. -- Likely fine, just needs verification.

- [ ] **Survey feature has no Interface target** (unlike all other features). It also has no Domain/Data dependency. Confirm it is excluded from this migration entirely. -- Affects scope.
