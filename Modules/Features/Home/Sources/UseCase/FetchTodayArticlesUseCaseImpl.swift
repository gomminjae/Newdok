import HomeDomain

public final class FetchTodayArticlesUseCaseImpl: FetchTodayArticlesUseCase {
    private let repository: HomeArticleRepository

    public init(repository: HomeArticleRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [HomeArticle] {
        try await repository.fetchTodayArticles()
    }
}
