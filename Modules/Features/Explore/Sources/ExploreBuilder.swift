import SwiftUI
import NetworkKit
import Shared
import ExploreInterface

public struct ExploreBuilder: ExploreBuildable {
    private let container: ExploreDIContainer

    public init(
        networkProvider: NetworkProviding,
        userInfoStore: UserInfoStoreProtocol,
        selectableItemStore: SelectableItemStoreProtocol,
        analytics: AnalyticsClient
    ) {
        self.container = ExploreDIContainer(
            networkProvider: networkProvider,
            userInfoStore: userInfoStore,
            selectableItemStore: selectableItemStore,
            analytics: analytics
        )
    }

    public func makeExploreView(
        landing: ExploreLanding?,
        onSearch: (() -> Void)?,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onEditProfile: @escaping () -> Void,
        onBrandTap: @escaping (String, AnalyticsListContext) -> Void
    ) -> AnyView {
        AnyView(
            ExploreView(
                viewModel: container.makeViewModel(),
                landing: landing,
                onSearch: onSearch,
                onSignup: onSignup,
                onLogin: onLogin,
                onEditProfile: onEditProfile,
                onBrandTap: onBrandTap
            )
        )
    }
}
