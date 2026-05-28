import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Search",
    dataDependencies: [.external(name: "Moya")],
    featureDependencies: [.featureData("Search"), .core],
    hasInterface: true,
    hasExample: true
)
