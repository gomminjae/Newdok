import Foundation

public protocol FetchArticleDetailUseCase: Sendable {
    func execute(articleId: String) async throws -> DetailArticleDetailResult
}
