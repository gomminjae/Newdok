import SwiftUI
import NetworkKit
import DatabaseKit
import DetailInterface

public struct DetailBuilder: DetailBuildable {
    private let container: DetailDIContainer

    public init(networkProvider: NetworkProviding, highlightDataSource: HighlightLocalDataSource) {
        self.container = DetailDIContainer(
            networkProvider: networkProvider,
            highlightDataSource: highlightDataSource
        )
    }

    public func makeBrandDetailView(id: String) -> AnyView {
        AnyView(BrandDetailView(viewModel: container.makeBrandDetailViewModel(id: id)))
    }

    public func makeArticleDetailView(id: String, isPastArticle: Bool) -> AnyView {
        AnyView(ArticleDetailView(viewModel: container.makeArticleDetailViewModel(id: id), isPastArticle: isPastArticle))
    }
}
