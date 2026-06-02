import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "App",
    organizationName: ProjectConfig.organizationName,
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "AU24ZRJ649",
            "SWIFT_VERSION": "6.0",
            "MARKETING_VERSION": "1.0.1",
            "CURRENT_PROJECT_VERSION": "1",
            "CODE_SIGN_STYLE": "Automatic"
        ],
        configurations: [
            .debug(
                name: "Debug",
                xcconfig: "../../Configurations/Debug.xcconfig"
            ),
            .release(
                name: "Release",
                xcconfig: "../../Configurations/Release.xcconfig"
            )
        ],
        defaultSettings: .recommended(excluding: [
            "ASSETCATALOG_COMPILER_APPICON_NAME",
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS",
            "PRODUCT_BUNDLE_IDENTIFIER"
        ])
    ),
    targets: [
        .target(
            name: "App",
            destinations: ProjectConfig.destinations,
            product: .app,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER)",
            deploymentTargets: ProjectConfig.deploymentTarget,
            infoPlist: .extendingDefault(
                with: [
                    "API_BASE_URL": "$(API_BASE_URL)",
                    "CFBundleDisplayName": "$(APP_DISPLAY_NAME)",
                    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                    "UILaunchScreen": [
                        "UIColorName": "AccentColor",
                        "UIImageName": ""
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
                            "CFBundleURLName": "$(PRODUCT_BUNDLE_IDENTIFIER)",
                            "CFBundleURLSchemes": ["newdok"]
                        ]
                    ],
                    "ITSAppUsesNonExemptEncryption": false
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                // Infrastructure
                .networkKit,
                .designSystem,
                .shared,
                .databaseKit,
                // Feature Interfaces
                .featureInterface("Auth"),
                .featureInterface("Home"),
                .featureInterface("Mypage"),
                .featureInterface("Explore"),
                .featureInterface("Subscribe"),
                .featureInterface("Bookmark"),
                .featureInterface("Detail"),
                .featureInterface("Search"),
                // Feature Implementations
                .feature("Auth"),
                .feature("Home"),
                .feature("Explore"),
                .feature("Subscribe"),
                .feature("Bookmark"),
                .feature("Detail"),
                .feature("Search"),
                .feature("Mypage"),
                .feature("Launch"),
                // External
                .external(name: "PopupView"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseCrashlytics"),
                .external(name: "KakaoSDKCommon"),
                .external(name: "KakaoSDKAuth"),
                .external(name: "KakaoSDKUser")
            ]
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
