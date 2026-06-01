import NetworkKit
import Shared
import DatabaseKit
import HomeDomain
import HomeData

@MainActor
final class HomeDIContainer {
    private let network: any NetworkService
    private let highlightDataSource: HighlightLocalDataSource
    private let appState: AppState

    init(
        networkProvider: NetworkProviding,
        highlightDataSource: HighlightLocalDataSource,
        appState: AppState
    ) {
        self.network = networkProvider.makeService()
        self.highlightDataSource = highlightDataSource
        self.appState = appState
    }

    func makeArticleRepository() -> HomeArticleRepository {
        HomeArticleRepositoryImpl(network: network)
    }

    func makeNewsletterRepository() -> HomeNewsletterRepository {
        HomeNewsletterRepositoryImpl(network: network)
    }

    func makeHighlightRepository() -> HighlightCountRepository {
        HighlightCountRepositoryImpl(dataSource: highlightDataSource)
    }

    func makeHomeViewModel() -> HomeViewModel {
        let articleRepo = makeArticleRepository()
        let newsletterRepo = makeNewsletterRepository()
        let highlightRepo = makeHighlightRepository()
        let highlightCounts = FetchHomeHighlightCountsUseCaseImpl(repository: highlightRepo)
        return HomeViewModel(
            fetchTodayArticles: FetchTodayArticlesUseCaseImpl(repository: articleRepo),
            fetchMonthArticles: FetchMonthArticlesUseCaseImpl(repository: articleRepo),
            fetchDayArticles: FetchDayArticlesUseCaseImpl(repository: articleRepo),
            fetchNewsletters: FetchHomeNewslettersUseCaseImpl(repository: newsletterRepo),
            decorateArticles: DecorateArticlesUseCaseImpl(highlightCountsUseCase: highlightCounts),
            refreshArticles: RefreshHomeArticlesUseCaseImpl(repository: articleRepo),
            loadReadIds: LoadReadArticleIdsUseCaseImpl(repository: articleRepo),
            saveReadIds: SaveReadArticleIdsUseCaseImpl(repository: articleRepo),
            extractArticleDays: ExtractArticleDaysUseCaseImpl(),
            mergeDayArticleSummary: MergeDayArticleSummaryUseCaseImpl(),
            appState: appState
        )
    }
}
