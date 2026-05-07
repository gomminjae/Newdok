import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "Survey",
    dependencies: [.core],
    hasResources: true,
    hasTests: true
)
