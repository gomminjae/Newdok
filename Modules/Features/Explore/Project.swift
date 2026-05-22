import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Explore",
    featureDependencies: [.featureData("Explore"), .core],
    hasInterface: true,
    hasExample: true
)
