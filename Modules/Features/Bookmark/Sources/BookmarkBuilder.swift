import Shared
import SwiftUI
import NetworkKit
import BookmarkInterface

public struct BookmarkBuilder: BookmarkBuildable {
    private let container: BookmarkDIContainer

    public init(networkProvider: NetworkProviding, analytics: AnalyticsClient) {
        self.container = BookmarkDIContainer(networkProvider: networkProvider, analytics: analytics)
    }

    public func makeBookmarkView(
        onSearch: (() -> Void)?,
        onLogin: @escaping () -> Void,
        onArticleTap: @escaping (String, AnalyticsListContext) -> Void
    ) -> AnyView {
        AnyView(
            BookmarkView(
                viewModel: container.makeViewModel(),
                onSearch: onSearch,
                onLogin: onLogin,
                onArticleTap: onArticleTap
            )
        )
    }
}
