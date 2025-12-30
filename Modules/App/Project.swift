import ProjectDescription

let project = Project(
    name: "App",
    organizationName: "Your Organization Name",
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "BASE_URL": "$(BASE_URL)",
                    "CFBundleName": "$(CFBundleDisplayName)",
                    "CFBundleDisplayName": "$(CFBundleDisplayName)",
                    "CFBundleShortVersionString": "1.0.0",
                    "CFBundleVersion": "1",
                    "UILaunchScreen": [
                        "UIColorName": "AccentColor",
                        "UIImageName": "",
                    ],
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true,
                        "NSExceptionDomains": [
                            "localhost": [
                                "NSExceptionAllowsInsecureHTTPLoads": true
                            ],
                            "3.38.79.19": [
                                "NSExceptionAllowsInsecureHTTPLoads": true
                            ]
                        ]
                    ],
                    "UIUserInterfaceStyle": "Light",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],

                    "NSCameraUsageDescription": "프로필 사진 촬영을 위해 카메라 접근이 필요합니다.",
                    "NSPhotoLibraryUsageDescription": "프로필 사진 선택을 위해 사진 라이브러리 접근이 필요합니다.",
                    "NSUserNotificationsUsageDescription": "새로운 뉴스레터 알림을 받기 위해 알림 권한이 필요합니다.",

                    "LSApplicationCategoryType": "public.app-category.news",
                    "CFBundleURLTypes": [
                        [
                            "CFBundleURLName": "com.newdok.app",
                            "CFBundleURLSchemes": ["newdok"]
                        ]
                    ],
                    "ITSAppUsesNonExemptEncryption": false
                ]
            ),
            sources: ["Sources/**"],
            resources: [
                "Resources/**"
            ],
            dependencies: [
                .project(target: "Core", path: "../Core"),
                .project(target: "DesignSystem", path: "../DesignSystem"),
                .project(target: "AppCoordinator", path: "../AppCoordinator"),
                .project(target: "Shared", path: "../Shared"),
                .external(name: "PopupView"),
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "$(ASSETCATALOG_COMPILER_APPICON_NAME)",
                    "DEVELOPMENT_TEAM": "$(DEVELOPMENT_TEAM)"
                ],
                configurations: [
                    .debug(name: "Debug", xcconfig: "../../Configurations/Development.xcconfig"),
                    .release(name: "Release", xcconfig: "../../Configurations/Production.xcconfig")
                ]
            )
        )
    ],
    schemes: [
        .scheme(
            name: "Newdok",
            shared: true,
            buildAction: .buildAction(targets: ["App"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        )
    ]
)

