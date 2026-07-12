import SwiftUI
import NetworkKit
import SubscribeInterface

public struct SubscribeBuilder: SubscribeBuildable {
    private let container: SubscribeDIContainer

    public init(networkProvider: NetworkProviding) {
        self.container = SubscribeDIContainer(networkProvider: networkProvider)
    }

    public func makeSubscribeView(
        onSearch: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onBrandTap: @escaping (String) -> Void
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
