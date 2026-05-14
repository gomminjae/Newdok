import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "NewdokWidget",
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
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS",
            "PRODUCT_BUNDLE_IDENTIFIER"
        ])
    ),
    targets: [
        .target(
            name: "NewdokWidget",
            destinations: ProjectConfig.destinations,
            product: .appExtension,
            bundleId: "$(PRODUCT_BUNDLE_IDENTIFIER).widget",
            deploymentTargets: ProjectConfig.deploymentTarget,
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "Newdok Widget",
                    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                    "APP_GROUP_ID": "$(APP_GROUP_ID)",
                    "NSExtension": [
                        "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
                    ]
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: "Support/NewdokWidget.entitlements",
            dependencies: [
                .shared
            ],
            settings: .settings(base: [
                "SWIFT_STRICT_CONCURRENCY": "complete",
                "SWIFT_ENABLE_EXPLICIT_MODULES": "YES"
            ])
        )
    ]
)
