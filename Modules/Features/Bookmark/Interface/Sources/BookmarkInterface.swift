import SwiftUI
import Shared

@MainActor
public protocol BookmarkBuildable {
    func makeBookmarkView(
        onSearch: (() -> Void)?,
        onLogin: @escaping () -> Void,
        onArticleTap: @escaping (String, AnalyticsListContext) -> Void
    ) -> AnyView
}
