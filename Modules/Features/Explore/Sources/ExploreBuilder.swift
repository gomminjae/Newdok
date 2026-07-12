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

    public func makeExploreView(
        exploreTrigger: UUID,
        onConsumePending: @escaping () -> (day: Int?, tab: Int)?,
        onSearch: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onEditProfile: @escaping () -> Void,
        onBrandTap: @escaping (String) -> Void
    ) -> AnyView {
        AnyView(
            ExploreView(
                viewModel: container.makeViewModel(),
                exploreTrigger: exploreTrigger,
                onConsumePending: onConsumePending,
                onSearch: onSearch,
                onSignup: onSignup,
                onLogin: onLogin,
                onEditProfile: onEditProfile,
                onBrandTap: onBrandTap
            )
        )
    }

    public func loadOptions() async throws {
        try await container.loadOptions()
    }
}
