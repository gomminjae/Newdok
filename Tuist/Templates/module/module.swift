import ProjectDescription

let nameAttribute = Template.Attribute.required("name")
let hasResourcesAttribute = Template.Attribute.optional("hasResources", default: "true")
let hasTestsAttribute = Template.Attribute.optional("hasTests", default: "true")

let template = Template(
    description: "A template for creating a new module",
    attributes: [
        nameAttribute,
        hasResourcesAttribute,
        hasTestsAttribute
    ],
    items: [
        .file(
            path: "Modules/\(nameAttribute)/Project.swift",
            templatePath: "project.stencil"
        ),
        .file(
            path: "Modules/\(nameAttribute)/Sources/\(nameAttribute)Main.swift",
            templatePath: "main.stencil"
        ),
        .file(
            path: "Modules/\(nameAttribute)/Tests/\(nameAttribute)Tests.swift",
            templatePath: "tests.stencil"
        ),
        .directory(
            path: "Modules/\(nameAttribute)/Resources",
            sourcePath: "Resources"
        )
    ]
)
