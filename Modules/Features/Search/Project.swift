import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Search",
    featureDependencies: [.featureData("Search"), .core],
    hasInterface: true,
    hasExample: true
)
