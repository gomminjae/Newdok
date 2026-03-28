import Foundation
import MypageDomain
import Core

public final class MypageStatsRepositoryImpl: MypageStatsRepository {
    private let articleNetwork: any NetworkService<ArticleAPI>
    private let newsletterNetwork: any NetworkService<NewsletterAPI>

    public init(
        articleNetwork: any NetworkService<ArticleAPI>,
        newsletterNetwork: any NetworkService<NewsletterAPI>
    ) {
        self.articleNetwork = articleNetwork
        self.newsletterNetwork = newsletterNetwork
    }

    public func fetchReceivedArticleCount() async throws -> Int {
        let response: MypageArticlesCountDTO = try await articleNetwork.request(.fetchReceivedArticleCount)
        return response.count
    }

    public func fetchSubscriptionCount() async throws -> Int {
        let response: MypageNewslettersCountDTO = try await newsletterNetwork.request(.fetchSubscriptionCount)
        return response.count
    }
}
