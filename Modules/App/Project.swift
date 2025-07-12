import ProjectDescription

let project = Project(
    name: "App",
    organizationName: "Your Organization Name",
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "com.minjae.Newdok",
            deploymentTargets: .iOS("17.0"),
            infoPlist: "Resources/Info.plist",
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "Core", path: "../Core"),
                .project(target: "DesignSystem", path: "../DesignSystem"),
                .project(target: "AppCoordinator", path: "../AppCoordinator"),
                .project(target: "Shared", path: "../Shared"),
            ]
        )
    ]
)


