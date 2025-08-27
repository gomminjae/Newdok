import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .remote(
            url: "https://github.com/Moya/Moya.git",
            requirement: .upToNextMajor(from: "15.0.0")
        ),
        .remote(
            url: "https://github.com/Swinject/Swinject.git",
            requirement: .upToNextMajor(from: "2.8.0")
        ), 
        .remote(
            url: "https://github.com/onevcat/Kingfisher", 
            requirement: .upToNextMajor(from: "8.0.0")
        ),
    ],
    platforms: [.iOS],
    productTypes: [
        "Moya": .staticFramework,
        "Alamofire": .staticFramework
    ]
)
