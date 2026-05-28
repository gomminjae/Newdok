import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Auth",
    domainDependencies: [.foundationKit],
    dataDependencies: [.external(name: "Moya")],
    featureDependencies: [.foundationKit, .featureData("Auth"), .core],
    testDependencies: [.foundationKit],
    hasInterface: true
)
