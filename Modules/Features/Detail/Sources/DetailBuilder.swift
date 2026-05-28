import SwiftUI
import Core
import DatabaseKit
import DetailInterface
import DetailDomain
import DetailData

public struct DetailBuilder: DetailBuildable {
    private let articleNetwork: any NetworkService<DetailArticleAPI>
    private let newsletterNetwork: any NetworkService<DetailNewsletterAPI>
    private let highlightDataSource: HighlightLocalDataSource

    public init(networkProvider: NetworkProviding, highlightDataSource: HighlightLocalDataSource) {
        self.articleNetwork = networkProvider.makeService(for: DetailArticleAPI.self)
        self.newsletterNetwork = networkProvider.makeService(for: DetailNewsletterAPI.self)
        self.highlightDataSource = highlightDataSource
    }

    public func makeBrandDetailView(id: String) -> AnyView {
        let brandRepository = DetailBrandRepositoryImpl(network: newsletterNetwork)
        let viewModel = BrandDetailViewModel(id: id, brandRepository: brandRepository)
        return AnyView(BrandDetailView(viewModel: viewModel))
    }

    public func makeArticleDetailView(id: String, isPastArticle: Bool) -> AnyView {
        let articleRepository = DetailArticleRepositoryImpl(network: articleNetwork)
        let highlightRepository = DetailHighlightRepositoryImpl(dataSource: highlightDataSource)
        let viewModel = ArticleDetailViewModel(
            id: id,
            fetchDetailUseCase: FetchArticleDetailUseCaseImpl(articleRepository: articleRepository),
            toggleBookmarkUseCase: ToggleArticleBookmarkUseCaseImpl(articleRepository: articleRepository),
            highlightRepository: highlightRepository
        )
        return AnyView(ArticleDetailView(viewModel: viewModel, isPastArticle: isPastArticle))
    }
}
