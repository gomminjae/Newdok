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
        subscribePopupPreference: SubscribePopupStorable,
        analytics: AnalyticsClient
    ) {
        self.container = DetailDIContainer(
            networkProvider: networkProvider,
            highlightDataSource: highlightDataSource,
            userInfoStore: userInfoStore,
            subscribePopupPreference: subscribePopupPreference,
            analytics: analytics
        )
    }

    public func makeBrandDetailView(
        id: String,
        source: AnalyticsContentSource = .unknown,
        onBack: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onGoHome: @escaping () -> Void,
        onArticleTap: @escaping (String, AnalyticsListContext) -> Void
    ) -> AnyView {
        AnyView(
            BrandDetailView(
                viewModel: container.makeBrandDetailViewModel(id: id, source: source),
                onBack: onBack,
                onSignup: onSignup,
                onGoHome: onGoHome,
                onArticleTap: onArticleTap
            )
        )
    }

    public func makeArticleDetailView(
        id: String,
        source: AnalyticsContentSource = .unknown,
        isPast: Bool,
        onBack: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            ArticleDetailView(
                viewModel: container.makeArticleDetailViewModel(id: id, kind: isPast ? .past : .current, source: source),
                isPastArticle: isPast,
                onBack: onBack
            )
        )
    }
}
