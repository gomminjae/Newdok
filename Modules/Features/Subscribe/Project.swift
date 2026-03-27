import ProjectDescription

let project = Project(
    name: "Subscribe",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "SubscribeInterface",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.subscribe.interface",
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
            name: "SubscribeDomain",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.subscribe.domain",
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
            name: "SubscribeData",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.subscribe.data",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Data/Sources/**"],
            dependencies: [
                .target(name: "SubscribeDomain"),
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
            name: "Subscribe",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.subscribe",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .target(name: "SubscribeInterface"),
                .target(name: "SubscribeDomain"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Shared", path: "../../Shared")
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
