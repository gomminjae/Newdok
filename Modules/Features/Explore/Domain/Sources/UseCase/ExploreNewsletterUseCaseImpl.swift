import Foundation

public final class ExploreNewsletterUseCaseImpl: ExploreNewsletterUseCase {
    private let repository: ExploreNewsletterRepository

    public init(repository: ExploreNewsletterRepository) {
        self.repository = repository
    }

    public func fetchNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand] {
        try await repository.fetchNewsletters(orderOpt: orderOpt, industry: industry, day: day)
    }

    public func fetchNewsletterBrand(id: String) async throws -> ExploreBrandDetail {
        try await repository.fetchNewsletterBrand(id: id)
    }

    public func fetchGuestNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand] {
        try await repository.fetchGuestAllNewsletters(orderOpt: orderOpt, industry: industry, day: day)
    }

    public func fetchGuestNewsletterBrand(id: String) async throws -> ExploreBrandDetail {
        try await repository.fetchGuestNewsletterBrand(id: id)
    }

    public func fetchRecommendation() async throws -> ExploreRecommendedNewsletter {
        try await repository.fetchRecommendation()
    }

    public func fetchOptionList() async throws -> ExploreOptionList {
        try await repository.fetchOptionList()
    }
}
