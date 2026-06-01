import SwiftUI
import NetworkKit
import ExploreInterface

public struct ExploreBuilder: ExploreBuildable {
    private let container: ExploreDIContainer

    public init(networkProvider: NetworkProviding) {
        self.container = ExploreDIContainer(networkProvider: networkProvider)
    }

    public func makeExploreView() -> AnyView {
        AnyView(ExploreView(viewModel: container.makeViewModel()))
    }

    public func loadOptions() async throws {
        try await container.loadOptions()
    }
}
