import Shared
import SwiftUI
import NetworkKit
import SubscribeInterface

public struct SubscribeBuilder: SubscribeBuildable {
    private let container: SubscribeDIContainer

    public init(networkProvider: NetworkProviding, analytics: AnalyticsClient) {
        self.container = SubscribeDIContainer(networkProvider: networkProvider, analytics: analytics)
    }

    public func makeSubscribeView(
        onSearch: (() -> Void)?,
        onLogin: @escaping () -> Void,
        onBrandTap: @escaping (String, AnalyticsListContext) -> Void
    ) -> AnyView {
        let viewModel = container.makeViewModel()
        return AnyView(
            SubscribeView(
                viewModel: viewModel,
                onSearch: onSearch,
                onLogin: onLogin,
                onBrandTap: onBrandTap
            )
        )
    }
}
