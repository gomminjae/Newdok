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
            resources: ["Resources/**"]
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
                 .project(target: "DesignSystem", path: "../../DesignSystem"),
            ]
        )
    ]
)
