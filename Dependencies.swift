import ProjectDescription

let dependencies = Dependencies(
  swiftPackageManager: [
    .remote(
      url: "https://github.com/Moya/Moya.git",
      requirement: .upToNextMajor(from: "15.0.0") // 최신 버전 확인 필요
    )
  ],
  platforms: [.iOS]
)

