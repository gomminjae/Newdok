import SwiftUI
import NetworkKit
import DatabaseKit
import Shared
import HomeInterface
import HomeDomain

public struct HomeBuilder: HomeBuildable {
    private let container: HomeDIContainer

    public init(
        networkProvider: NetworkProviding,
        highlightDataSource: HighlightLocalDataSource,
        appState: AppState,
        widgetSummaryPublisher: TodayWidgetSummaryPublishing? = nil
    ) {
        self.container = HomeDIContainer(
            networkProvider: networkProvider,
            highlightDataSource: highlightDataSource,
            appState: appState,
            widgetSummaryPublisher: widgetSummaryPublisher
        )
    }

    public func makeHomeView(
        onArticleTap: @escaping (String) -> Void,
        onSearch: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onExploreRecommendations: @escaping () -> Void,
        onExploreAllNewsletters: @escaping (Int?) -> Void
    ) -> AnyView {
        AnyView(
            HomeView(
                viewModel: container.makeHomeViewModel(),
                onArticleTap: onArticleTap,
                onSearch: onSearch,
                onSignup: onSignup,
                onLogin: onLogin,
                onExploreRecommendations: onExploreRecommendations,
                onExploreAllNewsletters: onExploreAllNewsletters
            )
        )
    }
}
