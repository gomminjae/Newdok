import ProjectDescription

let project = Project(
  name: "Domain",
  targets: [
    .target(
      name: "Domain",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "com.your.bundle.domain",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      resources: [],
      dependencies: []
    )
  ]
)

