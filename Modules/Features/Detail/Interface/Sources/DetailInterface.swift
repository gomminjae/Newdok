import SwiftUI
import Shared

@MainActor
public protocol DetailBuildable {
    func makeBrandDetailView(
        id: String,
        source: AnalyticsContentSource,
        onBack: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onGoHome: @escaping () -> Void,
        onArticleTap: @escaping (String, AnalyticsListContext) -> Void
    ) -> AnyView

    func makeArticleDetailView(
        id: String,
        source: AnalyticsContentSource,
        isPast: Bool,
        onBack: @escaping () -> Void
    ) -> AnyView
}
