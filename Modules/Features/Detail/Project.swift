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
        .project(target: "Shared", path: "../../Shared"),
        .project(target: "Core", path: "../../Core")
      ],
      settings: .settings(
        base: [
          "SWIFT_INSTALL_OBJC_HEADER": "NO",
          "SKIP_INSTALL": "YES",
          "SWIFT_STRICT_CONCURRENCY": "complete"
        ]
      )
    )
  ]
)
