import ProjectDescription

let project = Project(
    name: "DesignSystem",
    organizationName: "Your Organization Name",
    
    targets: [
        .target(
            name: "DesignSystem",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.designsystem",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [
                "Resources/**"
            ],
            dependencies: [
                .project(target: "Shared", path: "../Shared"),
                .external(name: "Kingfisher"),
                .external(name: "SDWebImage"),
                .external(name: "PopupView")
            ],
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
        )
    ],
    resourceSynthesizers: [
        .assets(),
        .fonts(),
        .strings()
    ]
)
