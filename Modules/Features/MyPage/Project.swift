import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Mypage",
    domainDependencies: [.foundationKit],
    dataDependencies: [],
    featureDependencies: [.external(name: "PopupView"), .foundationKit, .featureData("Mypage"), .networkKit],
    hasInterface: true,
    hasExample: true
)
