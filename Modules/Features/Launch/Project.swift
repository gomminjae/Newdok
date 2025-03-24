import ProjectDescription

let project = Project(
    name: "Launch",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "Launch",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.launch",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                 .project(target: "Core", path: "../../Core"),
                 .project(target: "DesignSystem", path: "../../DesignSystem"),
             ]
        ),
        .target(
            name: "LaunchTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.newdok.launch.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Launch"),
                .project(target: "Core", path: "../../Core"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
            ]
        )
    ]
)
