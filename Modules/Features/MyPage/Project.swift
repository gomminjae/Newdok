import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
    name: "Mypage",
    featureDependencies: [.external(name: "PopupView")]
)
