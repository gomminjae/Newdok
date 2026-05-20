import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Home",
    dataDependencies: [.databaseKit],
    hasExample: true
)
