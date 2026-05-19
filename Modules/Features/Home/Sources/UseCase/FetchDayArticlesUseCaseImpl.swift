import HomeDomain

public final class FetchDayArticlesUseCaseImpl: FetchDayArticlesUseCase {
    private let repository: HomeArticleRepository

    public init(repository: HomeArticleRepository) {
        self.repository = repository
    }

    public func execute(year: String, publicationMonth: String, publicationDate: String) async throws -> [HomeArticle] {
        try await repository.fetchDayArticles(year: year, publicationMonth: publicationMonth, publicationDate: publicationDate)
    }
}
