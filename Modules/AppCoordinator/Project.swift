import ProjectDescription

let project = Project(
    name: "AppCoordinator",
    targets: [
        .target(
            name: "AppCoordinator",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.appcoordinator",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                // Interface only — no concrete Feature imports
                .project(target: "AuthInterface", path: "../Features/Auth"),
                .project(target: "HomeInterface", path: "../Features/Home"),
                .project(target: "MypageInterface", path: "../Features/MyPage"),
                .project(target: "ExploreInterface", path: "../Features/Explore"),
                .project(target: "SubscribeInterface", path: "../Features/Subscribe"),
                .project(target: "SearchInterface", path: "../Features/Search"),
                .project(target: "BookmarkInterface", path: "../Features/Bookmark"),
                .project(target: "DetailInterface", path: "../Features/Detail"),
                .project(target: "LaunchInterface", path: "../Features/Launch"),
                // Infrastructure
                .project(target: "Core", path: "../Core"),
                .project(target: "DesignSystem", path: "../DesignSystem"),
                .project(target: "Shared", path: "../Shared"),
                // ExploreDomain (for LoadOptionsUseCase)
                .project(target: "ExploreDomain", path: "../Features/Explore"),
                .external(name: "Swinject")
            ],
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
        )
    ]
)
