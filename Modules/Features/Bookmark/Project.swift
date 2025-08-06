import ProjectDescription

   let project = Project(
       name: "Bookmark",
       organizationName: "Newdok",
       targets: [
           .target(
               name: "Bookmark",
               destinations: .iOS,
               product: .staticFramework,
               bundleId: "com.newdok.bookmark",
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
           ),
           .target(
               name: "BookmarkTests",
               destinations: .iOS,
               product: .unitTests,
               bundleId: "com.newdok.bookmark.tests",
               deploymentTargets: .iOS("17.0"),
               infoPlist: .default,
               sources: ["Tests/**"],
               dependencies: [
                   .target(name: "Bookmark"),
                   .project(target: "DesignSystem", path: "../../DesignSystem"),
                   .project(target: "Shared", path: "../../Shared"),
                   .project(target: "Domain", path: "../../Domain"),
               ]
           )
       ]
   )
