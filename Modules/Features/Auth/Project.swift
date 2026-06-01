import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Auth",
    domainDependencies: [.foundationKit],
    dataDependencies: [],
    featureDependencies: [.foundationKit, .featureData("Auth"), .networkKit],
    testDependencies: [.foundationKit],
    hasInterface: true
)
