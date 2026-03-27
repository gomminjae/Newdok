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
    ]
)
#endif

let package = Package(
    name: "MyProjectDependencies",
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        .package(url: "https://github.com/exyte/PopupView.git", from: "4.1.13"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
    ]
)
