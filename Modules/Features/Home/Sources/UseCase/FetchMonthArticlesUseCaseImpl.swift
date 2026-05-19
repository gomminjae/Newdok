import HomeDomain

public final class FetchMonthArticlesUseCaseImpl: FetchMonthArticlesUseCase {
    private let repository: HomeArticleRepository

    public init(repository: HomeArticleRepository) {
        self.repository = repository
    }

    public func execute(year: String, publicationMonth: String) async throws -> [HomeArticles] {
        try await repository.fetchArticles(year: year, publicationMonth: publicationMonth)
    }
}
