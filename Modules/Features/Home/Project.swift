import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Home",
    dataDependencies: [.databaseKit, .external(name: "Moya")],
    featureDependencies: [.foundationKit, .featureData("Home"), .core, .databaseKit],
    hasInterface: true,
    hasExample: true
)
