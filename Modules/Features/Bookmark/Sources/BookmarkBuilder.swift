import SwiftUI
import NetworkKit
import BookmarkInterface

public struct BookmarkBuilder: BookmarkBuildable {
    private let container: BookmarkDIContainer

    public init(networkProvider: NetworkProviding) {
        self.container = BookmarkDIContainer(networkProvider: networkProvider)
    }

    public func makeBookmarkView(
        onSearch: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onArticleTap: @escaping (String) -> Void
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
