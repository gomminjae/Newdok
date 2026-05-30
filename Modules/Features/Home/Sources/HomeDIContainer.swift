import Core
import Shared
import DatabaseKit
import HomeDomain
import HomeData

@MainActor
final class HomeDIContainer {
    private let articleNetwork: any NetworkService<HomeArticleAPI>
    private let newsletterNetwork: any NetworkService<HomeNewsletterAPI>
    private let highlightDataSource: HighlightLocalDataSource
    private let appState: AppState

    init(
        networkProvider: NetworkProviding,
        highlightDataSource: HighlightLocalDataSource,
        appState: AppState = .shared
    ) {
        self.articleNetwork = networkProvider.makeService(for: HomeArticleAPI.self)
        self.newsletterNetwork = networkProvider.makeService(for: HomeNewsletterAPI.self)
        self.highlightDataSource = highlightDataSource
        self.appState = appState
    }

    func makeArticleRepository() -> HomeArticleRepository {
        HomeArticleRepositoryImpl(network: articleNetwork)
    }

    func makeNewsletterRepository() -> HomeNewsletterRepository {
        HomeNewsletterRepositoryImpl(network: newsletterNetwork)
    }

    func makeHighlightRepository() -> HighlightCountRepository {
        HighlightCountRepositoryImpl(dataSource: highlightDataSource)
    }

    func makeHomeViewModel() -> HomeViewModel {
        let articleRepo = makeArticleRepository()
        let newsletterRepo = makeNewsletterRepository()
        let highlightRepo = makeHighlightRepository()
        return HomeViewModel(
            fetchTodayArticles: FetchTodayArticlesUseCaseImpl(repository: articleRepo),
            fetchMonthArticles: FetchMonthArticlesUseCaseImpl(repository: articleRepo),
            fetchDayArticles: FetchDayArticlesUseCaseImpl(repository: articleRepo),
            fetchNewsletters: FetchHomeNewslettersUseCaseImpl(repository: newsletterRepo),
            fetchHighlightCounts: FetchHomeHighlightCountsUseCaseImpl(repository: highlightRepo),
            refreshArticles: RefreshHomeArticlesUseCaseImpl(repository: articleRepo),
            loadReadIds: LoadReadArticleIdsUseCaseImpl(repository: articleRepo),
            saveReadIds: SaveReadArticleIdsUseCaseImpl(repository: articleRepo),
            appState: appState
        )
    }
}
