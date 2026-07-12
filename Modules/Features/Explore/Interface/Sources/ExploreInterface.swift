import SwiftUI

@MainActor
public protocol ExploreBuildable {
    func makeExploreView(
        exploreTrigger: UUID,
        onConsumePending: @escaping () -> (day: Int?, tab: Int)?,
        onSearch: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onEditProfile: @escaping () -> Void,
        onBrandTap: @escaping (String) -> Void
    ) -> AnyView
    func loadOptions() async throws
}
