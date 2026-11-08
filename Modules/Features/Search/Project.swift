import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Search",
    interfaceDependencies: [.shared],
    dataDependencies: [],
    featureDependencies: [.featureData("Search"), .networkKit],
    hasInterface: true,
    hasExample: true
)
