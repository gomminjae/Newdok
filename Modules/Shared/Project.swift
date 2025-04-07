 import ProjectDescription

 let project = Project(
   name: "Shared",
   targets: [
     .target(
       name: "Shared",
       destinations: .iOS,
       product: .staticFramework,
       bundleId: "com.Newdok.shared",
       deploymentTargets: .iOS("17.0"),
       infoPlist: .default,
       sources: ["Sources/**"],
     )
   ]
 )

