import SwiftUI
import SearchInterface
import SearchDomain
import DesignSystem
import Shared

public struct SearchViewFactoryImpl: SearchViewFactory {
    private let viewModelProvider: @MainActor () -> SearchViewModel

    public init(viewModelProvider: @MainActor @escaping () -> SearchViewModel) {
        self.viewModelProvider = viewModelProvider
    }

    @MainActor public func makeSearchView() -> AnyView {
        let vm = viewModelProvider()
        return AnyView(SearchView(viewModel: vm))
    }
}
