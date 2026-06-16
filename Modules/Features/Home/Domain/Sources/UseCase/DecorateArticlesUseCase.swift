import Foundation

public protocol DecorateArticlesUseCase: Sendable {
    func execute(articles: [HomeArticle], readIds: Set<Int>, refreshHighlightCounts: Bool) async -> [HomeArticle]
}

public extension DecorateArticlesUseCase {
    func execute(articles: [HomeArticle], readIds: Set<Int>) async -> [HomeArticle] {
        await execute(articles: articles, readIds: readIds, refreshHighlightCounts: true)
    }
}
