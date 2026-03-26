import ProjectDescription

let project = Project(
    name: "Mypage",
    organizationName: "Newdok",
    targets: [
        .target(
            name: "MypageInterface",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.newdok.mypage.interface",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Interface/Sources/**"],
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
        ),
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
                .target(name: "MypageInterface"),
                .project(target: "DesignSystem", path: "../../DesignSystem"),
                .project(target: "Shared", path: "../../Shared"),
                .project(target: "Domain", path: "../../Domain"),
                .external(name: "PopupView")
            ],
            settings: .settings(
                base: [
                    "SKIP_INSTALL": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete"
                ]
            )
        )
    ]
)
