import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Subscribe",
    featureDependencies: [.featureData("Subscribe"), .core],
    hasInterface: true,
    hasExample: true
)
