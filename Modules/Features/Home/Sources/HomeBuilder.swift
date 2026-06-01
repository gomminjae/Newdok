import SwiftUI
import NetworkKit
import DatabaseKit
import HomeInterface

public struct HomeBuilder: HomeBuildable {
    private let container: HomeDIContainer

    public init(networkProvider: NetworkProviding, highlightDataSource: HighlightLocalDataSource) {
        self.container = HomeDIContainer(
            networkProvider: networkProvider,
            highlightDataSource: highlightDataSource
        )
    }

    public func makeHomeView() -> AnyView {
        AnyView(HomeView(viewModel: container.makeHomeViewModel()))
    }
}
