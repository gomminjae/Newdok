import ExploreDomain

public final class FetchExploreBrandDetailUseCaseImpl: FetchExploreBrandDetailUseCase {
    private let repository: ExploreNewsletterRepository

    public init(repository: ExploreNewsletterRepository) {
        self.repository = repository
    }

    public func execute(id: String) async throws -> ExploreBrandDetail {
        try await repository.fetchNewsletterBrand(id: id)
    }
}
