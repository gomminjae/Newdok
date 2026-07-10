import SwiftUI

@MainActor
public protocol DetailBuildable {
    func makeBrandDetailView(
        id: String,
        onBack: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onGoHome: @escaping () -> Void,
        onArticleTap: @escaping (String) -> Void
    ) -> AnyView

    func makeArticleDetailView(
        id: String,
        isPast: Bool,
        onBack: @escaping () -> Void
    ) -> AnyView
}
