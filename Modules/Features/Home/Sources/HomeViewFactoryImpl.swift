import SwiftUI
import HomeInterface
import HomeDomain
import DesignSystem
import Shared

public struct HomeViewFactoryImpl: HomeViewFactory {
    private let viewModelProvider: @MainActor () -> HomeViewModel

    public init(viewModelProvider: @MainActor @escaping () -> HomeViewModel) {
        self.viewModelProvider = viewModelProvider
    }

    @MainActor public func makeHomeView() -> AnyView {
        let vm = viewModelProvider()
        return AnyView(HomeView(viewModel: vm))
    }
}
