import SwiftUI
import NetworkKit
import SearchInterface

public struct SearchBuilder: SearchBuildable {
    private let container: SearchDIContainer

    public init(networkProvider: NetworkProviding) {
        self.container = SearchDIContainer(networkProvider: networkProvider)
    }

    public func makeSearchView(
        onBack: @escaping () -> Void,
        onBrandTap: @escaping (String) -> Void,
        onFeedback: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            SearchView(
                viewModel: container.makeSearchViewModel(),
                onBack: onBack,
                onBrandTap: onBrandTap,
                onFeedback: onFeedback
            )
        )
    }
}
