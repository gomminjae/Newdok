import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "AppCoordinator",
    dependencies: [
        .featureInterface("Auth"),
        .featureInterface("Home"),
        .featureInterface("Mypage"),
        .featureInterface("Explore"),
        .featureInterface("Subscribe"),
        .featureInterface("Search"),
        .featureInterface("Bookmark"),
        .featureInterface("Detail"),
        .featureInterface("Launch"),
        .core,
        .designSystem,
        .shared,
        .featureDomain("Explore"),
        .external(name: "Swinject")
    ]
)
