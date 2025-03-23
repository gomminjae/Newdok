import ProjectDescription

let project = Project(
    name: "A",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "A",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.a",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"]
        ),
        .target(
            name: "ATests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.newdok.a.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "A")
            ]
        )
    ]
)
