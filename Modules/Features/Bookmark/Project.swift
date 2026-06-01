import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Bookmark",
    dataDependencies: [],
    featureDependencies: [.featureData("Bookmark"), .networkKit],
    hasInterface: true,
    hasExample: true
)
