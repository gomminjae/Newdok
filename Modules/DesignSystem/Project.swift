import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "DesignSystem",
    dependencies: [
        .shared,
        .external(name: "Kingfisher"),
        .external(name: "PopupView")
    ],
    hasResources: true,
    resourceSynthesizers: [
        .assets(),
        .fonts(),
        .strings()
    ]
)
