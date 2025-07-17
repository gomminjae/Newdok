import ProjectDescription


 let project = Project(
     name: "Withdraw",
     organizationName: "Newdok",
     targets: [
         .target(
             name: "Withdraw",
             destinations: .iOS,
             product: .staticFramework,
             bundleId: "com.newdok.withdraw",
             deploymentTargets: .iOS("17.0"),
             infoPlist: .default,
             sources: ["Sources/**"],
             resources: ["Resources/**"],
             dependencies: [
                  .project(target: "DesignSystem", path: "../../DesignSystem"),
                  .project(target: "Domain", path: "../../Domain"),
                  .project(target: "Data", path: "../../Data"),
             ]
         ),
         .target(
             name: "WithdrawTests",
             destinations: .iOS,
             product: .unitTests,
             bundleId: "com.newdok.withdraw.tests",
             deploymentTargets: .iOS("17.0"),
             infoPlist: .default,
             sources: ["Tests/**"],
             dependencies: [
                 .target(name: "Withdraw"),
                 .project(target: "DesignSystem", path: "../../DesignSystem"),
                 .project(target: "Shared", path: "../../Shared"),
             ]
         )
     ]
 )
