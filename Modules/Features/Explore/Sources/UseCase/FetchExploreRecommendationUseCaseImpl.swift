import ExploreDomain

public final class FetchExploreRecommendationUseCaseImpl: FetchExploreRecommendationUseCase {
    private let repository: ExploreNewsletterRepository

    public init(repository: ExploreNewsletterRepository) {
        self.repository = repository
    }

    public func execute() async throws -> ExploreRecommendedNewsletter {
        try await repository.fetchRecommendation()
    }
}
