import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Bookmark",
    featureDependencies: [.featureData("Bookmark"), .core],
    hasInterface: true,
    hasExample: true
)
