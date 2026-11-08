import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Bookmark",
    interfaceDependencies: [.shared],
    dataDependencies: [],
    featureDependencies: [.featureData("Bookmark"), .networkKit],
    hasInterface: true,
    hasExample: true
)
