import ExploreDomain

public final class FetchGuestExploreBrandDetailUseCaseImpl: FetchGuestExploreBrandDetailUseCase {
    private let repository: ExploreNewsletterRepository

    public init(repository: ExploreNewsletterRepository) {
        self.repository = repository
    }

    public func execute(id: String) async throws -> ExploreBrandDetail {
        try await repository.fetchGuestNewsletterBrand(id: id)
    }
}
