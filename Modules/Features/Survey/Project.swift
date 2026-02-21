import ProjectDescription

let project = Project(
    name: "Survey",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "Survey",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.survey",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "Core", path: "../../Core")
            ],
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
        ),
        .target(
            name: "SurveyTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.newdok.survey.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Survey"),
                 .project(target: "DesignSystem", path: "../../DesignSystem")
            ]
        )
    ]
)
