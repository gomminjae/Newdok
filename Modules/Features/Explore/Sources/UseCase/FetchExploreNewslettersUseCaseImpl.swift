import ExploreDomain

public final class FetchExploreNewslettersUseCaseImpl: FetchExploreNewslettersUseCase {
    private let repository: ExploreNewsletterRepository

    public init(repository: ExploreNewsletterRepository) {
        self.repository = repository
    }

    public func execute(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand] {
        try await repository.fetchNewsletters(orderOpt: orderOpt, industry: industry, day: day)
    }
}
