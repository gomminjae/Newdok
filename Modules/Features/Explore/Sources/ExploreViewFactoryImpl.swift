import SwiftUI
import ExploreInterface
import Domain
import DesignSystem
import Shared

public struct ExploreViewFactoryImpl: ExploreViewFactory {
    private let viewModelProvider: @MainActor () -> ExploreViewModel

    public init(viewModelProvider: @MainActor @escaping () -> ExploreViewModel) {
        self.viewModelProvider = viewModelProvider
    }

    @MainActor public func makeExploreView() -> AnyView {
        let vm = viewModelProvider()
        return AnyView(ExploreView(viewModel: vm))
    }
}
