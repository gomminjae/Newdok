import ProjectDescription

let project = Project(
    name: "Home",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "Home",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.home",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Domain", path: "../../Domain"),
                .project(target: "Shared", path: "../../Shared"),
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
            name: "HomeTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.newdok.home.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Home"), 
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Shared", path: "../../Shared"),
            ]
        ),
        .target(
            name: "HomeDemo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.newdok.home.demo",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Home Demo",
                    "UILaunchScreen": [:],
                    "UIUserInterfaceStyle": "Light",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ]
                ]
            ),
            sources: ["DemoApp/Sources/**"],
            resources: [],
            dependencies: [
                .target(name: "Home"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Shared", path: "../../Shared"),
                .project(target: "Domain", path: "../../Domain"),
                .project(target: "Data", path: "../../Data"),
                .project(target: "Core", path: "../../Core")
            ]
        )
    ]
)
