import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Home",
    interfaceDependencies: [.shared],
    dataDependencies: [.databaseKit],
    featureDependencies: [.foundationKit, .featureData("Home"), .networkKit, .databaseKit],
    hasInterface: true,
    hasExample: true
)
