import ProjectDescription

let dependencies = Dependencies(
  swiftPackageManager: [
    .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0"))
  ],
  platforms: [.iOS]
)

