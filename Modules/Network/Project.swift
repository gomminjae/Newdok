import ProjectDescription

let project = Project(
    name: "Network",
    organizationName: "Your Organization Name",
    targets: [
        .target(
            name: "Network",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.minjae.core",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: [
                .external(name: "Moya"),
                .project(target: "Shared", path: "../Shared"), 
            ]
        )
    ]
)

