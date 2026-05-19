import HomeDomain

public final class LoadReadArticleIdsUseCaseImpl: LoadReadArticleIdsUseCase {
    private let repository: HomeArticleRepository

    public init(repository: HomeArticleRepository) {
        self.repository = repository
    }

    public func execute() -> Set<Int> {
        repository.loadReadArticleIds()
    }
}
