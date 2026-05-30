import SwiftUI
import Core
import BookmarkInterface

public struct BookmarkBuilder: BookmarkBuildable {
    private let container: BookmarkDIContainer

    public init(networkProvider: NetworkProviding) {
        self.container = BookmarkDIContainer(networkProvider: networkProvider)
    }

    public func makeBookmarkView() -> AnyView {
        AnyView(BookmarkView(viewModel: container.makeViewModel()))
    }
}
