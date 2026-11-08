import SwiftUI
import Shared

@MainActor
public protocol HomeBuildable {
    func makeHomeView(
        onArticleTap: @escaping (String, AnalyticsListContext) -> Void,
        onSearch: (() -> Void)?,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onExploreRecommendations: @escaping () -> Void,
        onExploreAllNewsletters: @escaping (Int?) -> Void
    ) -> AnyView
}
