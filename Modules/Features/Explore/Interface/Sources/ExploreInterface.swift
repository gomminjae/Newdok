import SwiftUI
import Shared

public enum ExploreLanding: Hashable, Sendable {
    case recommendations
    case allNewsletters(day: Int?)
}

@MainActor
public protocol ExploreBuildable {
    func makeExploreView(
        landing: ExploreLanding?,
        onSearch: (() -> Void)?,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onEditProfile: @escaping () -> Void,
        onBrandTap: @escaping (String, AnalyticsListContext) -> Void
    ) -> AnyView
}
