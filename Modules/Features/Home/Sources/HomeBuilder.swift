import SwiftUI
import NetworkKit
import DatabaseKit
import Shared
import HomeInterface

public struct HomeBuilder: HomeBuildable {
    private let container: HomeDIContainer

    public init(
        networkProvider: NetworkProviding,
        highlightDataSource: HighlightLocalDataSource,
        appState: AppState
    ) {
        self.container = HomeDIContainer(
            networkProvider: networkProvider,
            highlightDataSource: highlightDataSource,
            appState: appState
        )
    }

    public func makeHomeView(
        onArticleTap: @escaping (String) -> Void,
        onSearch: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onGoToExplore: @escaping (Int?, Int) -> Void
    ) -> AnyView {
        AnyView(
            HomeView(
                viewModel: container.makeHomeViewModel(),
                onArticleTap: onArticleTap,
                onSearch: onSearch,
                onSignup: onSignup,
                onLogin: onLogin,
                onGoToExplore: onGoToExplore
            )
        )
    }
}
