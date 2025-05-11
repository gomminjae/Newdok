// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MyProjectDependencies",
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"), 
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.0.0"),
        .package(url: "https://github.com/exyte/PopupView.git", from: "4.1.3"),
    ]
)
