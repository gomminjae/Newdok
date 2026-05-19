import BookmarkDomain

public final class FetchBookmarkedArticlesUseCaseImpl: FetchBookmarkedArticlesUseCase {
    private let repository: BookmarkRepository

    public init(repository: BookmarkRepository) {
        self.repository = repository
    }

    public func execute(interest: String?, sortBy: String?) async throws -> BookmarkedArticles {
        try await repository.fetchBookmarkArticles(interest: interest, sortBy: sortBy)
    }
}
