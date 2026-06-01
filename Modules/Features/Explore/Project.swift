import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Explore",
    dataDependencies: [],
    featureDependencies: [.featureData("Explore"), .networkKit],
    hasInterface: true,
    hasExample: true
)
