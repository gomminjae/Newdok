import SwiftUI
import NetworkKit
import SubscribeInterface

public struct SubscribeBuilder: SubscribeBuildable {
    private let container: SubscribeDIContainer

    public init(networkProvider: NetworkProviding) {
        self.container = SubscribeDIContainer(networkProvider: networkProvider)
    }

    public func makeSubscribeView() -> AnyView {
        let viewModel = container.makeViewModel()
        return AnyView(SubscribeView(viewModel: viewModel))
    }
}
