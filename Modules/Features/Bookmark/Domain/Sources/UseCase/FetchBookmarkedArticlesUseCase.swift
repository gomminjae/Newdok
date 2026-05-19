import Foundation

public protocol FetchBookmarkedArticlesUseCase: Sendable {
    func execute(interest: String?, sortBy: String?) async throws -> BookmarkedArticles
}
