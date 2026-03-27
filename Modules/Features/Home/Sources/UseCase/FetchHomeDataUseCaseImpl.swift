import HomeDomain

public final class FetchHomeDataUseCaseImpl: FetchHomeDataUseCase, @unchecked Sendable {
    private let newsletterRepo: HomeNewsletterRepository
    private let articleRepo: HomeArticleRepository

    public init(newsletterRepo: HomeNewsletterRepository, articleRepo: HomeArticleRepository) {
        self.newsletterRepo = newsletterRepo
        self.articleRepo = articleRepo
    }

    public func fetchTodayData() async throws -> HomeData {
        let articles = try await articleRepo.fetchTodayArticles()
        let newsletters = try await newsletterRepo.fetchActiveSubscription()

        return HomeData(
            articles: articles,
            activeNewsletters: newsletters
        )
    }

    public func fetchMonthlyData(year: String, month: String) async throws -> [HomeArticles] {
        try await articleRepo.fetchArticles(year: year, publicationMonth: month)
    }

    public func fetchDayArticles(year: String, month: String, day: String) async throws -> [HomeArticle] {
        try await articleRepo.fetchDayArticles(year: year, publicationMonth: month, publicationDate: day)
    }

    public func decorateTodayArticles(_ articles: [HomeArticle], readArticleIds: Set<Int>) -> [HomeArticle] {
        let mapped = articles.map { applyReadStatus(to: $0, readArticleIds: readArticleIds) }
        return prioritize(mapped)
    }

    public func unreadCount(in articles: [HomeArticle]) -> Int {
        articles.reduce(into: 0) { count, article in
            if !isRead(article) { count += 1 }
        }
    }

    private func applyReadStatus(to article: HomeArticle, readArticleIds: Set<Int>) -> HomeArticle {
        guard readArticleIds.contains(article.articleId) else { return article }
        return HomeArticle(
            brandName: article.brandName,
            imageUrl: article.imageUrl,
            articleTitle: article.articleTitle,
            articleId: article.articleId,
            status: "Read",
            publishDate: article.publishDate
        )
    }

    private func prioritize(_ articles: [HomeArticle]) -> [HomeArticle] {
        articles.sorted { lhs, rhs in
            let lhsRead = isRead(lhs)
            let rhsRead = isRead(rhs)

            if lhsRead != rhsRead {
                return !lhsRead
            }

            return lhs.articleId > rhs.articleId
        }
    }

    public func refresh() async throws {
        try await articleRepo.refresh()
    }

    private func isRead(_ article: HomeArticle) -> Bool {
        article.status.caseInsensitiveCompare("Read") == .orderedSame
    }
}
