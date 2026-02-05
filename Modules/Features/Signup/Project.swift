import ProjectDescription

let project = Project(
    name: "Signup",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "Signup",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.signup",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                  .project(target: "DesignSystem", path: "../../DesignSystem"),
                  .project(target: "Auth", path: "../Auth"),
                  .project(target: "Domain", path: "../../Domain"),
                  .project(target: "Shared", path: "../../Shared"),
                  .project(target: "Detail", path: "../Detail"),
                  .project(target: "Core", path: "../../Core"),
             ],
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES"
                ]
            )
        ),
        .target(
            name: "SignupTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.newdok.signup.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "Signup"),
                 .project(target: "DesignSystem", path: "../../DesignSystem"),
            ]
        )
    ]
)
