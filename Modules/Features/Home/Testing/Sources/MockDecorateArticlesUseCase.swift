import Foundation
import HomeDomain

public final class MockDecorateArticlesUseCase: DecorateArticlesUseCase {
    public var handler: (([HomeArticle], Set<Int>) -> [HomeArticle])?
    public private(set) var executeCallCount = 0
    public private(set) var lastArticles: [HomeArticle]?
    public private(set) var lastReadIds: Set<Int>?

    public init() {}

    public func execute(articles: [HomeArticle], readIds: Set<Int>) async -> [HomeArticle] {
        executeCallCount += 1
        lastArticles = articles
        lastReadIds = readIds
        if let handler { return handler(articles, readIds) }
        return articles
    }
}
