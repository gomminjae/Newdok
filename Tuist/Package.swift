// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyProjectDependencies",
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "3.0.0"),
        .package(url: "https://github.com/exyte/PopupView.git", from: "4.1.13"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.56.0"),
    ]
)
