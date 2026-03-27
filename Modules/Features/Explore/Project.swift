import ProjectDescription

let project = Project(
    name: "Explore",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "ExploreInterface",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.explore.interface",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Interface/Sources/**"],
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
        ),
        .target(
            name: "Explore",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.explore",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "ExploreInterface"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Shared", path: "../../Shared"),
                .project(target: "Domain", path: "../../Domain")
            ],
            settings: .settings(
                base: [
                    "SWIFT_INSTALL_OBJC_HEADER": "NO",
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
        ),
        .target(
            name: "ExploreTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.newdok.explore.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Explore"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Shared", path: "../../Shared"),
                .project(target: "Domain", path: "../../Domain")
            ]
        )
    ]
)
