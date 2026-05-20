import Foundation
import Core
import DatabaseKit

@MainActor
final class AppDependencies {
    private let networkProvider: NetworkProviding

    let highlightDataSource: HighlightLocalDataSource

    lazy var userNetwork: MoyaNetworkService<UserAPI> = {
        MoyaNetworkService(provider: networkProvider.makeAuthProvider())
    }()

    lazy var newsletterNetwork: MoyaNetworkService<NewsletterAPI> = {
        MoyaNetworkService(provider: networkProvider.makeNewsletterProvider())
    }()

    lazy var articleNetwork: MoyaNetworkService<ArticleAPI> = {
        MoyaNetworkService(provider: networkProvider.makeArticleProvider())
    }()

    lazy var searchNetwork: MoyaNetworkService<SearchAPI> = {
        MoyaNetworkService(provider: networkProvider.makeSearchProvider())
    }()

    init(
        networkProvider: NetworkProviding = NetworkProvider(),
        highlightDataSource: HighlightLocalDataSource = DefaultHighlightLocalDataSource.shared
    ) {
        self.networkProvider = networkProvider
        self.highlightDataSource = highlightDataSource
    }
}
