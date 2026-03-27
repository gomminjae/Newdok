import SwiftUI
import SubscribeInterface
import SubscribeDomain
import DesignSystem
import Shared

public struct SubscribeViewFactoryImpl: SubscribeViewFactory {
    private let viewModelProvider: @MainActor () -> SubscribeViewModel

    public init(viewModelProvider: @MainActor @escaping () -> SubscribeViewModel) {
        self.viewModelProvider = viewModelProvider
    }

    @MainActor public func makeSubscribeView() -> AnyView {
        let vm = viewModelProvider()
        return AnyView(SubscribeView(viewModel: vm))
    }
}
