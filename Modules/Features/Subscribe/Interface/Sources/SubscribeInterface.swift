import SwiftUI
import Shared

@MainActor
public protocol SubscribeBuildable {
    func makeSubscribeView(
        onSearch: (() -> Void)?,
        onLogin: @escaping () -> Void,
        onBrandTap: @escaping (String, AnalyticsListContext) -> Void
    ) -> AnyView
}
