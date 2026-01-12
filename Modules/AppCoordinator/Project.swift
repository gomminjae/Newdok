import ProjectDescription

let project = Project(
  name: "AppCoordinator",
  targets: [
    .target(
      name: "AppCoordinator",
      destinations: .iOS,
      product: .staticFramework,
      bundleId: "com.newdok.appcoordinator",
      deploymentTargets: .iOS("17.0"),
      infoPlist: .default,
      sources: ["Sources/**"],
      dependencies: [
        .project(target: "Signup", path: "../Features/Signup"),
        .project(target: "Auth", path: "../Features/Auth"),
        .project(target: "Survey", path: "../Features/Survey"),
        .project(target: "Launch", path: "../Features/Launch"),
        .project(target: "Home", path: "../Features/Home"),
        .project(target: "Mypage", path: "../Features/MyPage"),
        .project(target: "Explore", path: "../Features/Explore"),
        .project(target: "Subscribe", path: "../Features/Subscribe"), 
        .project(target: "Search", path: "../Features/Search"),
        .project(target: "Bookmark", path: "../Features/Bookmark"),
        .project(target: "Detail", path: "../Features/Detail"), 
        .project(target: "Recovery", path: "../Features/Recovery"),
        .project(target: "Withdraw", path: "../Features/Withdraw"),
        .project(target: "Data", path: "../Data"),
        .project(target: "Domain", path: "../Domain"),
        .project(target: "Core", path: "../Core"),
        .project(target: "DesignSystem", path: "../DesignSystem"),
        .project(target: "Shared", path: "../Shared"),
        .external(name: "Swinject"),
      ],
      settings: .settings(
        base: [
          "SKIP_INSTALL": "YES"
        ]
      )
    )
  ]
)
