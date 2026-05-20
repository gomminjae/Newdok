import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Detail",
    dataDependencies: [.databaseKit],
    hasExample: true
)
