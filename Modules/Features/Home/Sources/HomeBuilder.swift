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

    public func makeHomeView() -> AnyView {
        AnyView(HomeView(viewModel: container.makeHomeViewModel()))
    }
}
