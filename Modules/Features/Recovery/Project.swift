import ProjectDescription

  let project = Project(
      name: "Recovery",
      organizationName: "Newdok",
      targets: [
          .target(
              name: "Recovery",
              destinations: .iOS,
              product: .staticFramework,
              bundleId: "com.newdok.Recovery",
              deploymentTargets: .iOS("17.0"),
              infoPlist: .default,
              sources: ["Sources/**"],
              resources: ["Resources/**"],
              dependencies: [
                  .project(target: "DesignSystem", path: "../../DesignSystem"),
                  .project(target: "Shared", path: "../../Shared"),
                  .project(target: "Domain", path: "../../Domain"),
                  .external(name: "Kingfisher"), 
               ]
          )
      ]
  )
