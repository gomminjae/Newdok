import HomeDomain

public final class SaveReadArticleIdsUseCaseImpl: SaveReadArticleIdsUseCase {
    private let repository: HomeArticleRepository

    public init(repository: HomeArticleRepository) {
        self.repository = repository
    }

    public func execute(_ ids: Set<Int>) {
        repository.saveReadArticleIds(ids)
    }
}
