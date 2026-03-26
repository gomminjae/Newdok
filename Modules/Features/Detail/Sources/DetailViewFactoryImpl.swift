import SwiftUI
import DetailInterface
import Domain
import DesignSystem
import Shared

public struct DetailViewFactoryImpl: DetailViewFactory {
    private let brandDetailViewModelProvider: @MainActor (String) -> BrandDetailViewModel
    private let articleDetailViewModelProvider: @MainActor (String) -> ArticleDetailViewModel

    public init(
        brandDetailViewModelProvider: @MainActor @escaping (String) -> BrandDetailViewModel,
        articleDetailViewModelProvider: @MainActor @escaping (String) -> ArticleDetailViewModel
    ) {
        self.brandDetailViewModelProvider = brandDetailViewModelProvider
        self.articleDetailViewModelProvider = articleDetailViewModelProvider
    }

    @MainActor public func makeBrandDetailView(id: String) -> AnyView {
        let vm = brandDetailViewModelProvider(id)
        return AnyView(BrandDetailView(viewModel: vm))
    }

    @MainActor public func makeArticleDetailView(id: String, isPastArticle: Bool) -> AnyView {
        let vm = articleDetailViewModelProvider(id)
        return AnyView(ArticleDetailView(viewModel: vm, isPastArticle: isPastArticle))
    }
}
