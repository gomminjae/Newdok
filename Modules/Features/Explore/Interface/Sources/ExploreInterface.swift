import SwiftUI

public enum ExploreLanding: Hashable, Sendable {
    case recommendations
    case allNewsletters(day: Int?)
}

@MainActor
public protocol ExploreBuildable {
    func makeExploreView(
        landing: ExploreLanding?,
        onSearch: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onEditProfile: @escaping () -> Void,
        onBrandTap: @escaping (String) -> Void
    ) -> AnyView
    func loadOptions() async throws
}
