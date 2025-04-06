import ProjectDescription

let project = Project(
    name: "B",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "B",
            destinations: .iOS,
            product: .app,
            bundleId: "com.newdok.b",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                    "UIUserInterfaceStyle": "Light",
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                 .project(target: "AppCoordinator", path: "../../AppCoordinator"),
            ]
        ),
        .target(
            name: "BTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.newdok.b.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "B")
            ]
        )
    ]
)
