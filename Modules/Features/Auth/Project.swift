import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Auth",
    domainDependencies: [.foundationKit],
    featureDependencies: [.foundationKit, .featureData("Auth"), .core],
    testDependencies: [.foundationKit],
    hasInterface: true
)
