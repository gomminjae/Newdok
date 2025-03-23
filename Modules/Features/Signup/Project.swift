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
            resources: ["Resources/**"]
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
                .target(name: "Signup")
            ]
        )
    ]
)
