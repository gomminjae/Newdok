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
        .remote(
            url: "https://github.com/SDWebImage/SDWebImage.git",
            requirement: .upToNextMajor(from: "5.0.0")
        ),
        .remote(
            url: "https://github.com/exyte/PopupView.git",
            requirement: .upToNextMajor(from: "4.1.13")
        ),
    ],
    platforms: [.iOS],
    productTypes: [
        "Moya": .staticFramework,
        "Alamofire": .staticFramework,
        "Kingfisher": .staticFramework,
        "SDWebImage": .staticFramework,
        "PopupView": .framework
    ]
)
