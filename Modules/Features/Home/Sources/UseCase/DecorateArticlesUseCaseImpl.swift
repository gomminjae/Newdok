import HomeDomain

public final class DecorateArticlesUseCaseImpl: DecorateArticlesUseCase {
    private let highlightCountsUseCase: FetchHomeHighlightCountsUseCase

    public init(highlightCountsUseCase: FetchHomeHighlightCountsUseCase) {
        self.highlightCountsUseCase = highlightCountsUseCase
    }

    public func execute(articles: [HomeArticle], readIds: Set<Int>) async -> [HomeArticle] {
        let withStatus = articles.map { applyReadStatus(to: $0, readIds: readIds) }
        let prioritized = prioritize(withStatus)
        return await applyHighlightCounts(prioritized)
    }

    private func applyReadStatus(to article: HomeArticle, readIds: Set<Int>) -> HomeArticle {
        guard readIds.contains(article.articleId) else { return article }
        return HomeArticle(
            brandName: article.brandName,
            imageUrl: article.imageUrl,
            articleTitle: article.articleTitle,
            articleId: article.articleId,
            status: .read,
            publishDate: article.publishDate
        )
    }

    private func prioritize(_ articles: [HomeArticle]) -> [HomeArticle] {
        articles.sorted { lhs, rhs in
            let lhsRead = lhs.status.isRead
            let rhsRead = rhs.status.isRead
            if lhsRead != rhsRead { return !lhsRead }
            return lhs.articleId > rhs.articleId
        }
    }

    private func applyHighlightCounts(_ articles: [HomeArticle]) async -> [HomeArticle] {
        guard !articles.isEmpty else { return articles }
        let counts = await highlightCountsUseCase.execute(articleIds: articles.map(\.articleId))
        return articles.map { article in
            let count = counts[article.articleId] ?? 0
            return count == article.highlightCount ? article : article.withHighlightCount(count)
        }
    }
}
