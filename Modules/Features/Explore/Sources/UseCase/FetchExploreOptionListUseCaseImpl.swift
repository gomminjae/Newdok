import ExploreDomain

public final class FetchExploreOptionListUseCaseImpl: FetchExploreOptionListUseCase {
    private let repository: ExploreNewsletterRepository

    public init(repository: ExploreNewsletterRepository) {
        self.repository = repository
    }

    public func execute() async throws -> ExploreOptionList {
        try await repository.fetchOptionList()
    }
}
