import HomeDomain

public final class FetchHomeHighlightCountsUseCaseImpl: FetchHomeHighlightCountsUseCase {
    private let repository: HighlightCountRepository

    public init(repository: HighlightCountRepository) {
        self.repository = repository
    }

    public func execute(articleIds: [Int]) async -> [Int: Int] {
        await repository.highlightCounts(forArticleIds: articleIds)
    }
}
