import ProjectDescription

   let project = Project(
       name: "Search",
       organizationName: "Newdok",
       targets: [
           .target(
               name: "Search",
               destinations: .iOS,
               product: .staticFramework,
               bundleId: "com.newdok.search",
               deploymentTargets: .iOS("17.0"),
               infoPlist: .default,
               sources: ["Sources/**"],
               resources: ["Resources/**"],
               dependencies: [
                   .project(target: "DesignSystem", path: "../../DesignSystem"),
                   .project(target: "Shared", path: "../../Shared"),
                   .project(target: "Domain", path: "../../Domain"),
                ],
               settings: .settings(
                   base: [
                       "SWIFT_INSTALL_OBJC_HEADER": "NO",
                       "SKIP_INSTALL": "YES"
                   ]
               )
           )
       ]
   )
