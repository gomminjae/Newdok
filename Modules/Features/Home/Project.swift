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
                .external(name: "Kingfisher"),
                .external(name: "Lottie"),
             ]
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
        )
    ]
)
