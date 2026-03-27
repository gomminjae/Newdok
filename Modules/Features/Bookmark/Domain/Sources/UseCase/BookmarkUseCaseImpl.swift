import Foundation

public final class BookmarkUseCaseImpl: BookmarkUseCase {
    private let repository: BookmarkRepository

    public init(repository: BookmarkRepository) {
        self.repository = repository
    }

    public func fetchBookmarkedArticles(interest: String?, sortBy: String?) async throws -> BookmarkedArticles {
        try await repository.fetchBookmarkArticles(interest: interest, sortBy: sortBy)
    }

    public func toggleBookmarkStatus(articleId: String) async throws {
        try await repository.changeBookmarkState(articleId: articleId)
    }

    public func fetchBookmarkedInterests() async throws -> [BookmarkInterest] {
        try await repository.fetchBookmarkedInterest()
    }
}
