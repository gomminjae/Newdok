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
            resources: ["Resources/**"]
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
                .target(name: "Home")
            ]
        )
    ]
)
