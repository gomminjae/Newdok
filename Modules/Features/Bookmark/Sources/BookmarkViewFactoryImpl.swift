import SwiftUI
import BookmarkInterface
import Domain
import DesignSystem
import Shared

public struct BookmarkViewFactoryImpl: BookmarkViewFactory {
    private let viewModelProvider: @MainActor () -> BookmarkViewModel

    public init(viewModelProvider: @MainActor @escaping () -> BookmarkViewModel) {
        self.viewModelProvider = viewModelProvider
    }

    @MainActor public func makeBookmarkView() -> AnyView {
        let vm = viewModelProvider()
        return AnyView(BookmarkView(viewModel: vm))
    }
}
