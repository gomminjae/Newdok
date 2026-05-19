import Foundation

public protocol FetchMonthArticlesUseCase: Sendable {
    func execute(year: String, publicationMonth: String) async throws -> [HomeArticles]
}
