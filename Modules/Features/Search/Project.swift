import ProjectDescription

let project = Project(
    name: "Search",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "SearchInterface",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.search.interface",
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
            name: "SearchDomain",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.search.domain",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Domain/Sources/**"],
            dependencies: [
                .project(target: "Shared", path: "../../Shared")
            ],
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
        ),
        .target(
            name: "SearchData",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.search.data",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Data/Sources/**"],
            dependencies: [
                .target(name: "SearchDomain"),
                .project(target: "Core", path: "../../Core")
            ],
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
        ),
        .target(
            name: "Search",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.search",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "SearchInterface"),
                .target(name: "SearchDomain"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Shared", path: "../../Shared")
            ],
            settings: .settings(
                base: [
                    "SWIFT_INSTALL_OBJC_HEADER": "NO",
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
        )
    ]
)
