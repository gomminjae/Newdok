 import ProjectDescription

 let project = Project(
   name: "Shared",
   targets: [
     .target(
       name: "Shared",
       destinations: .iOS,
       product: .staticFramework,
       bundleId: "com.newdok.shared",
       deploymentTargets: .iOS("17.0"),
       infoPlist: .default,
       sources: ["Sources/**"],
       settings: .settings(
         base: [
           "SKIP_INSTALL": "YES",
           "SWIFT_STRICT_CONCURRENCY": "complete"
         ]
       )
     )
   ]
 )
