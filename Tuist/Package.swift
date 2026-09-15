// swift-tools-version:5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "Moya": .framework,
        "Swinject": .framework,
        "Kingfisher": .framework,
        "PopupView": .framework,
        "KakaoSDKCommon": .framework,
        "KakaoSDKAuth": .framework,
        "KakaoSDKUser": .framework,
    ],
    // 패키지의 deployment target은 타깃 수준에 생성되므로 baseSettings로 덮어쓸 수 없다.
    // 앱에서 사용하는 외부 소스 타깃도 ProjectConfig와 동일한 iOS 18 기준으로 빌드한다.
    targetSettings: Dictionary(uniqueKeysWithValues: [
        "Alamofire",
        "Firebase",
        "FirebaseAnalyticsTarget",
        "FirebaseAnalyticsWrapper",
        "FirebaseCore",
        "FirebaseCoreExtension",
        "FirebaseCoreInternal",
        "FirebaseCrashlytics",
        "FirebaseCrashlyticsSwift",
        "FirebaseInstallations",
        "FirebaseRemoteConfigInterop",
        "FirebaseSessions",
        "FirebaseSessionsObjC",
        "GoogleAdsOnDeviceConversionTarget",
        "GoogleAppMeasurementTarget",
        "GoogleDataTransport",
        "GoogleUtilities-AppDelegateSwizzler",
        "GoogleUtilities-Environment",
        "GoogleUtilities-Logger",
        "GoogleUtilities-MethodSwizzler",
        "GoogleUtilities-NSData",
        "GoogleUtilities-Network",
        "GoogleUtilities-Reachability",
        "GoogleUtilities-UserDefaults",
        "third-party-IsAppEncrypted",
        "KakaoSDKAuth",
        "KakaoSDKCommon",
        "KakaoSDKUser",
        "Kingfisher",
        "Moya",
        "PopupView",
        "FBLPromises",
        "Promises",
        "Swinject",
        "nanopb",
        "SwiftUIIntrospect",
    ].map { ($0, Settings.settings(base: ["IPHONEOS_DEPLOYMENT_TARGET": "18.0"])) })
)
#endif

let package = Package(
    name: "MyProjectDependencies",
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        .package(url: "https://github.com/exyte/PopupView.git", from: "4.1.13"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.19.1"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk.git", from: "2.22.0"),
    ]
)
