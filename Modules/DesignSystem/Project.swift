import ProjectDescription

let project = Project(
    name: "DesignSystem",
    organizationName: "Your Organization Name",
    
    targets: [
        .target(
            name: "DesignSystem",
            destinations: .iOS,
            product: .framework, 
            bundleId: "com.minjae.designsystem",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: []
        )
    ]
)

