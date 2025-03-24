import ProjectDescription

let project = Project(
    name: "B",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "B",
            destinations: .iOS,
            product: .app,
            bundleId: "com.newdok.b",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                 .project(target: "Launch", path: "../../Features/Launch"),
                 .project(target: "Auth", path: "../../Features/Auth"),
                 .project(target: "Home", path: "../../Features/Home"),
                 .project(target: "Signup", path: "../../Features/Signup"),
            ]
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
