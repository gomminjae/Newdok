import ProjectDescription

let project = Project(
    name: "B",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "B",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.b",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"]
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
