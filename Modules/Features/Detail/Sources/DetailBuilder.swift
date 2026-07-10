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

    public func makeBrandDetailView(
        id: String,
        onBack: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onGoHome: @escaping () -> Void,
        onArticleTap: @escaping (String) -> Void
    ) -> AnyView {
        AnyView(
            BrandDetailView(
                viewModel: container.makeBrandDetailViewModel(id: id),
                onBack: onBack,
                onSignup: onSignup,
                onGoHome: onGoHome,
                onArticleTap: onArticleTap
            )
        )
    }

    public func makeArticleDetailView(
        id: String,
        isPast: Bool,
        onBack: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            ArticleDetailView(
                viewModel: container.makeArticleDetailViewModel(id: id),
                isPastArticle: isPast,
                onBack: onBack
            )
        )
    }
}
