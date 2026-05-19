import BookmarkDomain

public final class ToggleBookmarkStatusUseCaseImpl: ToggleBookmarkStatusUseCase {
    private let repository: BookmarkRepository

    public init(repository: BookmarkRepository) {
        self.repository = repository
    }

    public func execute(articleId: String) async throws {
        try await repository.changeBookmarkState(articleId: articleId)
    }
}
