import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Bookmark",
    dataDependencies: [.external(name: "Moya")],
    featureDependencies: [.featureData("Bookmark"), .core],
    hasInterface: true,
    hasExample: true
)
