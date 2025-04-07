import ProjectDescription

let project = Project(
  name: "Data",
  targets: [
    .target(
      name: "Data",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "com.your.bundle.data",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      resources: [],
      dependencies: [
        .project(target: "Network", path: "../Network"),
        .project(target: "Domain", path: "../Domain"), 
      ]
    )
  ]
)

