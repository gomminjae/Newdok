import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Subscribe",
    dataDependencies: [],
    featureDependencies: [.featureData("Subscribe"), .networkKit],
    hasInterface: true,
    hasExample: true
)
