import ProjectDescription

let project = Project(
    name: "Features",
    organizationName: "Your Organization Name",
    targets: [
        .target(
            name: "Features",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.minjae.features",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "DesignSystem", path: "../DesignSystem"),
                .project(target: "Core", path: "../Core")
            ]
        )
    ]
)

