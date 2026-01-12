import ProjectDescription

let project = Project(
    name: "ExploreDemo",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "ExploreDemo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.newdok.explore.demo",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Explore Demo",
                    "UILaunchScreen": [:],
                    "UIUserInterfaceStyle": "Light",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ]
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "Explore", path: "../../Features/Explore"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Core", path: "../../Core"),
                .project(target: "Shared", path: "../../Shared"),
                .project(target: "Domain", path: "../../Domain"),
                .project(target: "Data", path: "../../Data")
            ],
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES"
                ]
            )
        )
    ]
)
