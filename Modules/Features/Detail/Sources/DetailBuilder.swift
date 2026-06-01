import SwiftUI
import NetworkKit
import DatabaseKit
import Shared
import DetailInterface

public struct DetailBuilder: DetailBuildable {
    private let container: DetailDIContainer

    public init(
        networkProvider: NetworkProviding,
        highlightDataSource: HighlightLocalDataSource,
        userInfoStore: UserInfoStoreProtocol,
        subscribePopupPreference: SubscribePopupStorable
    ) {
        self.container = DetailDIContainer(
            networkProvider: networkProvider,
            highlightDataSource: highlightDataSource,
            userInfoStore: userInfoStore,
            subscribePopupPreference: subscribePopupPreference
        )
    }

    public func makeBrandDetailView(id: String) -> AnyView {
        AnyView(BrandDetailView(viewModel: container.makeBrandDetailViewModel(id: id)))
    }

    public func makeArticleDetailView(id: String, isPastArticle: Bool) -> AnyView {
        AnyView(ArticleDetailView(viewModel: container.makeArticleDetailViewModel(id: id), isPastArticle: isPastArticle))
    }
}
