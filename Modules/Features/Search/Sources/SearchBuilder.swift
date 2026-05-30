import SwiftUI
import Core
import SearchInterface

public struct SearchBuilder: SearchBuildable {
    private let container: SearchDIContainer

    public init(networkProvider: NetworkProviding) {
        self.container = SearchDIContainer(networkProvider: networkProvider)
    }

    public func makeSearchView() -> AnyView {
        AnyView(SearchView(viewModel: container.makeSearchViewModel()))
    }
}
