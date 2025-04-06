// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "MyProjectDependencies",
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0")
    ]
)
