import NetworkKit
import Shared
import DatabaseKit
import DetailDomain
import DetailData

@MainActor
final class DetailDIContainer {
    private let analytics: AnalyticsClient
    private let network: any NetworkService
    private let highlightDataSource: HighlightLocalDataSource
    private let userInfoStore: UserInfoStoreProtocol
    private let subscribePopupPreference: SubscribePopupStorable

    init(
        networkProvider: NetworkProviding,
        highlightDataSource: HighlightLocalDataSource,
        userInfoStore: UserInfoStoreProtocol,
        subscribePopupPreference: SubscribePopupStorable,
        analytics: AnalyticsClient
    ) {
        self.analytics = analytics
        self.network = networkProvider.makeService()
        self.highlightDataSource = highlightDataSource
        self.userInfoStore = userInfoStore
        self.subscribePopupPreference = subscribePopupPreference
    }

    func makeArticleRepository() -> DetailArticleRepository {
        DetailArticleRepositoryImpl(network: network)
    }

    func makeBrandRepository() -> DetailBrandRepository {
        DetailBrandRepositoryImpl(network: network)
    }

    func makeHighlightRepository() -> DetailHighlightRepository {
        DetailHighlightRepositoryImpl(dataSource: highlightDataSource)
    }

    func makeBrandDetailViewModel(id: String, source: AnalyticsContentSource) -> BrandDetailViewModel {
        BrandDetailViewModel(id: id, brandRepository: makeBrandRepository(), popupPreference: subscribePopupPreference, userInfoStore: userInfoStore, source: source, analytics: analytics)
    }

    func makeArticleDetailViewModel(id: String, kind: AnalyticsArticleKind, source: AnalyticsContentSource) -> ArticleDetailViewModel {
        let articleRepo = makeArticleRepository()
        return ArticleDetailViewModel(
            id: id,
            kind: kind,
            source: source,
            fetchDetailUseCase: FetchArticleDetailUseCaseImpl(articleRepository: articleRepo),
            toggleBookmarkUseCase: ToggleArticleBookmarkUseCaseImpl(articleRepository: articleRepo),
            highlightRepository: makeHighlightRepository(),
            analytics: analytics
        )
    }
}
