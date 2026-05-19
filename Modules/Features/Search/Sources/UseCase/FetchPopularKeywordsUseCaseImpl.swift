import SearchDomain
import Shared

public final class FetchPopularKeywordsUseCaseImpl: FetchPopularKeywordsUseCase {
    private let repository: SearchRepository

    public init(repository: SearchRepository) {
        self.repository = repository
    }

    public func execute() async throws -> PopularKeywordList {
        try await repository.fetchPopularKeywords()
    }
}
