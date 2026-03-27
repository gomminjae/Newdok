import ProjectDescription

let project = Project(
    name: "Bookmark",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "BookmarkInterface",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.bookmark.interface",
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
            name: "Bookmark",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.bookmark",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "BookmarkInterface"),
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
            name: "BookmarkTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.newdok.bookmark.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Bookmark"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Shared", path: "../../Shared"),
                .project(target: "Domain", path: "../../Domain")
            ]
        )
    ]
)
