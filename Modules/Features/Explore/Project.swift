import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Explore",
    interfaceDependencies: [.shared],
    dataDependencies: [],
    featureDependencies: [.featureData("Explore"), .networkKit],
    hasInterface: true,
    hasExample: true
)
