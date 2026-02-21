import ProjectDescription

let project = Project(
  name: "Domain",
  targets: [
    .target(
      name: "Domain",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "com.newdok.domain",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      resources: [],
      dependencies: [
        .project(target: "Shared", path: "../Shared")
      ],
      settings: .settings(
        base: [
          "SKIP_INSTALL": "YES",
          "SWIFT_STRICT_CONCURRENCY": "complete"
        ]
      )
    )
  ]
)
