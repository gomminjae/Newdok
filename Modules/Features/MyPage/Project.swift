import ProjectDescription

 let project = Project(
     name: "Mypage",
     organizationName: "Newdok",
     targets: [
         .target(
             name: "Mypage",
             destinations: .iOS,
             product: .staticFramework,
             bundleId: "com.newdok.mypage",
             deploymentTargets: .iOS("17.0"),
             infoPlist: .default,
             sources: ["Sources/**"],
             resources: ["Resources/**"],
             dependencies: [
                 .project(target: "DesignSystem", path: "../../DesignSystem"),
                 .project(target: "Shared", path: "../../Shared"),
                 .external(name: "PopupView")
             ],
             settings: .settings(
                 base: [
                     "SKIP_INSTALL": "YES"
                 ]
             )
         )
     ]
 )
