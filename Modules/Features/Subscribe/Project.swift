import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Subscribe",
    dataDependencies: [.external(name: "Moya")],
    featureDependencies: [.featureData("Subscribe"), .core],
    hasInterface: true,
    hasExample: true
)
