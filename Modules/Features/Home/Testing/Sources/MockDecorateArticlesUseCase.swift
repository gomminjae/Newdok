import Foundation
import HomeDomain

public final class MockDecorateArticlesUseCase: DecorateArticlesUseCase {
    public var handler: (([HomeArticle], Set<Int>) -> [HomeArticle])?
    public private(set) var executeCallCount = 0
    public private(set) var lastArticles: [HomeArticle]?
    public private(set) var lastReadIds: Set<Int>?
    public private(set) var lastRefreshHighlightCounts: Bool?

    public init() {}

    public func execute(articles: [HomeArticle], readIds: Set<Int>, refreshHighlightCounts: Bool) async -> [HomeArticle] {
        executeCallCount += 1
        lastArticles = articles
        lastReadIds = readIds
        lastRefreshHighlightCounts = refreshHighlightCounts
        if let handler { return handler(articles, readIds) }
        return articles
    }
}
