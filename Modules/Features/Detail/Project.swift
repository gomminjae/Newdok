import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Detail",
    dataDependencies: [.databaseKit, .external(name: "Moya")],
    featureDependencies: [.featureData("Detail"), .core, .databaseKit, .foundationKit],
    hasInterface: true,
    hasExample: true
)
