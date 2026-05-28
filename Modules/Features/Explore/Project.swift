import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Explore",
    dataDependencies: [.external(name: "Moya")],
    featureDependencies: [.featureData("Explore"), .core],
    hasInterface: true,
    hasExample: true
)
