import ProjectDescription

let project = Project(
    name: "Explore",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "Explore",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.Explore",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Core", path: "../../Core"),
                .project(target: "Shared", path: "../../Shared"),
                .project(target: "Domain", path: "../../Domain"),
            ]
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
                .project(target: "Core", path: "../../Core"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Shared", path: "../../Shared"),
                .project(target: "Domain", path: "../../Domain"),
            ]
        )
    ]
)
