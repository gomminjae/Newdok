import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "NetworkKit",
    dependencies: [
        .external(name: "Moya"),
        .shared
    ],
    hasTests: true
)
