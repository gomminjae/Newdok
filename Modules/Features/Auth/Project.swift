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
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
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
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
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
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
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
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
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
