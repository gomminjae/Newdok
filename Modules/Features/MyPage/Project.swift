import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Mypage",
    domainDependencies: [.foundationKit],
    dataDependencies: [.external(name: "Moya")],
    featureDependencies: [.external(name: "PopupView"), .foundationKit, .featureData("Mypage"), .core],
    hasInterface: true,
    hasExample: true
)
