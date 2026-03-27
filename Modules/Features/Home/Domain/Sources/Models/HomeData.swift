import Foundation

public struct HomeData: Sendable {
    public let articles: [HomeArticle]
    public let activeNewsletters: [HomeNewsletter]

    public init(articles: [HomeArticle], activeNewsletters: [HomeNewsletter]) {
        self.articles = articles
        self.activeNewsletters = activeNewsletters
    }
}
