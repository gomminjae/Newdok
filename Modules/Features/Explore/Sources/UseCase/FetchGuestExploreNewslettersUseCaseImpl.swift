import ExploreDomain

public final class FetchGuestExploreNewslettersUseCaseImpl: FetchGuestExploreNewslettersUseCase {
    private let repository: ExploreNewsletterRepository

    public init(repository: ExploreNewsletterRepository) {
        self.repository = repository
    }

    public func execute(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand] {
        try await repository.fetchGuestAllNewsletters(orderOpt: orderOpt, industry: industry, day: day)
    }
}
