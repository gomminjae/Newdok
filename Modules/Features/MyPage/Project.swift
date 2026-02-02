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
                 .project(target: "Domain", path: "../../Domain"),
                 .external(name: "PopupView")
             ],
             settings: .settings(
                 base: [
                     "SKIP_INSTALL": "YES"
                 ]
             )
         ),
         .target(
            name: "MypageDemo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.newdok.mypage.demo",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Mypage Demo",
                    "UILaunchScreen": [:],
                    "UIUserInterfaceStyle": "Light",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ]
                ]
            ),
            sources: ["DemoApp/Sources/**"],
            resources: [],
            dependencies: [
                .target(name: "Mypage"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Shared", path: "../../Shared"),
                .project(target: "Domain", path: "../../Domain"),
                .project(target: "Core", path: "../../Core"),
                .project(target: "Data", path: "../../Data"),
                .external(name: "PopupView")
            ]
        )
     ]
 )
