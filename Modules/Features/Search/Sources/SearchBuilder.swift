import Shared
import SwiftUI
import NetworkKit
import SearchInterface

public struct SearchBuilder: SearchBuildable {
    private let container: SearchDIContainer

    public init(networkProvider: NetworkProviding, analytics: AnalyticsClient) {
        self.container = SearchDIContainer(networkProvider: networkProvider, analytics: analytics)
    }

    public func makeSearchView(
        entryPoint: AnalyticsEntryPoint = .unknown,
        onBack: @escaping () -> Void,
        onBrandTap: @escaping (String, AnalyticsListContext) -> Void,
        onFeedback: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            SearchView(
                entryPoint: entryPoint,
                viewModel: container.makeSearchViewModel(),
                onBack: onBack,
                onBrandTap: onBrandTap,
                onFeedback: onFeedback
            )
        )
    }
}
