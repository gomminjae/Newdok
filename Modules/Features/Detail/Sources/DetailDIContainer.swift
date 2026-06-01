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

    init(
        networkProvider: NetworkProviding,
        highlightDataSource: HighlightLocalDataSource,
        userInfoStore: UserInfoStoreProtocol = UserInfoStore.shared
    ) {
        self.network = networkProvider.makeService()
        self.highlightDataSource = highlightDataSource
        self.userInfoStore = userInfoStore
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
        BrandDetailViewModel(id: id, brandRepository: makeBrandRepository(), popupPreference: SubscribePopupPreference.shared, userInfoStore: userInfoStore)
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
