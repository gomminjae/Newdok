import SwiftUI
import Core
import Shared
import DatabaseKit
import HomeInterface
import HomeDomain
import HomeData

public struct HomeBuilder: HomeBuildable {
    private let articleNetwork: any NetworkService<HomeArticleAPI>
    private let newsletterNetwork: any NetworkService<HomeNewsletterAPI>
    private let highlightDataSource: HighlightLocalDataSource

    public init(networkProvider: NetworkProviding, highlightDataSource: HighlightLocalDataSource) {
        self.articleNetwork = HomeNetworkFactory.makeArticleNetwork(networkProvider)
        self.newsletterNetwork = HomeNetworkFactory.makeNewsletterNetwork(networkProvider)
        self.highlightDataSource = highlightDataSource
    }

    public func makeHomeView() -> AnyView {
        let articleRepository = HomeArticleRepositoryImpl(network: articleNetwork)
        let newsletterRepository = HomeNewsletterRepositoryImpl(network: newsletterNetwork)
        let highlightRepository = HighlightCountRepositoryImpl(dataSource: highlightDataSource)
        let viewModel = HomeViewModel(
            fetchTodayArticles: FetchTodayArticlesUseCaseImpl(repository: articleRepository),
            fetchMonthArticles: FetchMonthArticlesUseCaseImpl(repository: articleRepository),
            fetchDayArticles: FetchDayArticlesUseCaseImpl(repository: articleRepository),
            fetchNewsletters: FetchHomeNewslettersUseCaseImpl(repository: newsletterRepository),
            fetchHighlightCounts: FetchHomeHighlightCountsUseCaseImpl(repository: highlightRepository),
            refreshArticles: RefreshHomeArticlesUseCaseImpl(repository: articleRepository),
            loadReadIds: LoadReadArticleIdsUseCaseImpl(repository: articleRepository),
            saveReadIds: SaveReadArticleIdsUseCaseImpl(repository: articleRepository),
            appState: AppState.shared
        )
        return AnyView(HomeView(viewModel: viewModel))
    }
}
