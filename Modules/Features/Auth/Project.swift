import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Auth",
    domainDependencies: [.foundationKit],
    dataDependencies: [
        .external(name: "KakaoSDKCommon"),
        .external(name: "KakaoSDKAuth"),
        .external(name: "KakaoSDKUser")
    ],
    featureDependencies: [.foundationKit, .featureData("Auth"), .networkKit],
    testDependencies: [.foundationKit],
    hasInterface: true
)
