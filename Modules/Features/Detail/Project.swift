import ProjectDescription

let project = Project(
  name: "Detail",
  targets: [
    .target(
      name: "Detail",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "com.newdok.detail",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .project(target: "Domain", path: "../../Domain"),
        .project(target: "DesignSystem", path: "../../DesignSystem"), 
        .external(name: "Kingfisher"), 
      ]
    )
  ]
)

