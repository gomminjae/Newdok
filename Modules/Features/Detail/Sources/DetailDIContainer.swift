import NetworkKit
import Shared
import DatabaseKit
import DetailDomain
import DetailData

@MainActor
final class DetailDIContainer {
    private let network: any NetworkService
    private let highlightDataSource: HighlightLocalDataSource
    private let userInfoStore: UserInfoStoreProtocol
    private let subscribePopupPreference: SubscribePopupStorable

    init(
        networkProvider: NetworkProviding,
        highlightDataSource: HighlightLocalDataSource,
        userInfoStore: UserInfoStoreProtocol,
        subscribePopupPreference: SubscribePopupStorable
    ) {
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

    func makeBrandDetailViewModel(id: String) -> BrandDetailViewModel {
        BrandDetailViewModel(id: id, brandRepository: makeBrandRepository(), popupPreference: subscribePopupPreference, userInfoStore: userInfoStore)
    }

    func makeArticleDetailViewModel(id: String) -> ArticleDetailViewModel {
        let articleRepo = makeArticleRepository()
        return ArticleDetailViewModel(
            id: id,
            fetchDetailUseCase: FetchArticleDetailUseCaseImpl(articleRepository: articleRepo),
            toggleBookmarkUseCase: ToggleArticleBookmarkUseCaseImpl(articleRepository: articleRepo),
            highlightRepository: makeHighlightRepository()
        )
    }
}
