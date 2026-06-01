import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Detail",
    dataDependencies: [.databaseKit],
    featureDependencies: [.featureData("Detail"), .networkKit, .databaseKit, .foundationKit],
    hasInterface: true,
    hasExample: true
)
