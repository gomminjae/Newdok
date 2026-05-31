import Foundation

public protocol DecorateArticlesUseCase: Sendable {
    func execute(articles: [HomeArticle], readIds: Set<Int>) async -> [HomeArticle]
}
