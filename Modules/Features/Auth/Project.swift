import ProjectDescription

let project = Project(
    name: "Auth",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "Auth",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.auth",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                 .project(target: "DesignSystem", path: "../../DesignSystem"),
            ]
        ),
        .target(
            name: "AuthTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.newdok.auth.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Auth"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
            ]
        )
    ]
)
