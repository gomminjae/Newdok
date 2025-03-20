import ProjectDescription

let project = Project(
    name: "Newdok",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "Newdok",
            destinations: .iOS,
            product: .app,
            bundleId: "com.minjae.Newdok",
            deploymentTargets: .iOS("17.0"),
            infoPlist: "Newdok/Info.plist",
            sources: ["Newdok/Source/**"],
            resources: ["Newdok/Resource/**"],
            entitlements: "Newdok/Newdok.entitlements",
            scripts: [
                .pre(
                    script: "pod install",
                    name: "Run CocoaPods",
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: []
        )
    ]
)

