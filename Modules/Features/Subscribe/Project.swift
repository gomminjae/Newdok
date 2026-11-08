import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Subscribe",
    interfaceDependencies: [.shared],
    dataDependencies: [],
    featureDependencies: [.featureData("Subscribe"), .networkKit],
    hasInterface: true,
    hasExample: true
)
