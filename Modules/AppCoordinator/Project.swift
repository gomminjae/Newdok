import ProjectDescription

let project = Project(
  name: "AppCoordinator",
  targets: [
    .target(
      name: "AppCoordinator",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "com.Newdok.appcoordinator",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .project(target: "Signup", path: "../Features/Signup"),
        .project(target: "Auth", path: "../Features/Auth"),
        .project(target: "Survey", path: "../Features/Survey"),
        .project(target: "Launch", path: "../Features/Launch"),
        .project(target: "Data", path: "../Data"),
        .project(target: "Domain", path: "../Domain"),
        .project(target: "Network", path: "../Network"),
        .project(target: "DesignSystem", path: "../DesignSystem"),
        .project(target: "Shared", path: "../Shared"),
        .external(name: "Swinject"),
      ]
    )
  ]
)
