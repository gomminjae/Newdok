import HomeDomain

public final class RefreshHomeArticlesUseCaseImpl: RefreshHomeArticlesUseCase {
    private let repository: HomeArticleRepository

    public init(repository: HomeArticleRepository) {
        self.repository = repository
    }

    public func execute() async throws {
        try await repository.refresh()
    }
}
