import Core
import Shared
import DatabaseKit
import DetailDomain
import DetailData

@MainActor
final class DetailDIContainer {
    private let articleNetwork: any NetworkService<DetailArticleAPI>
    private let newsletterNetwork: any NetworkService<DetailNewsletterAPI>
    private let highlightDataSource: HighlightLocalDataSource
    private let userInfoStore: UserInfoStoreProtocol

    init(
        networkProvider: NetworkProviding,
        highlightDataSource: HighlightLocalDataSource,
        userInfoStore: UserInfoStoreProtocol = UserInfoStore.shared
    ) {
        self.articleNetwork = networkProvider.makeService(for: DetailArticleAPI.self)
        self.newsletterNetwork = networkProvider.makeService(for: DetailNewsletterAPI.self)
        self.highlightDataSource = highlightDataSource
        self.userInfoStore = userInfoStore
    }

    func makeArticleRepository() -> DetailArticleRepository {
        DetailArticleRepositoryImpl(network: articleNetwork)
    }

    func makeBrandRepository() -> DetailBrandRepository {
        DetailBrandRepositoryImpl(network: newsletterNetwork)
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
