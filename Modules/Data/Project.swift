import ProjectDescription

let project = Project(
  name: "Data",
  packages: [
         .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
  ],
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
        .package(product: "Moya"),
      ]
    )
  ]
)

