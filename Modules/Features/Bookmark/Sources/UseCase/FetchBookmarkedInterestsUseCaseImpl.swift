import BookmarkDomain

public final class FetchBookmarkedInterestsUseCaseImpl: FetchBookmarkedInterestsUseCase {
    private let repository: BookmarkRepository

    public init(repository: BookmarkRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [BookmarkInterest] {
        try await repository.fetchBookmarkedInterest()
    }
}
