import Foundation

public protocol FetchDayArticlesUseCase: Sendable {
    func execute(year: String, publicationMonth: String, publicationDate: String) async throws -> [HomeArticle]
}
