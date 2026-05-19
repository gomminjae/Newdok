import Foundation

public protocol FetchTodayArticlesUseCase: Sendable {
    func execute() async throws -> [HomeArticle]
}
