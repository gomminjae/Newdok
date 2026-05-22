import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Detail",
    dataDependencies: [.databaseKit],
    featureDependencies: [.featureData("Detail"), .core, .databaseKit],
    hasInterface: true,
    hasExample: true
)
