import SwiftUI
import NetworkKit
import Shared
import ExploreInterface

public struct ExploreBuilder: ExploreBuildable {
    private let container: ExploreDIContainer

    public init(
        networkProvider: NetworkProviding,
        userInfoStore: UserInfoStoreProtocol,
        selectableItemStore: SelectableItemStoreProtocol
    ) {
        self.container = ExploreDIContainer(
            networkProvider: networkProvider,
            userInfoStore: userInfoStore,
            selectableItemStore: selectableItemStore
        )
    }

    public func makeExploreView() -> AnyView {
        AnyView(ExploreView(viewModel: container.makeViewModel()))
    }

    public func loadOptions() async throws {
        try await container.loadOptions()
    }
}
