import ExploreDomain
import NetworkKit
import Shared

public final class ExploreNewsletterRepositoryImpl: ExploreNewsletterRepository {
    private let network: any NetworkService

    public init(network: any NetworkService) {
        self.network = network
    }

    public func fetchNewsletters(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand] {
        let response = try await network.request(FetchExploreAllNewsletterBrands(orderOpt: orderOpt, industry: industry, day: day))
        return response.map { $0.toDomain() }
    }

    public func fetchGuestAllNewsletters(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand] {
        let response = try await network.request(FetchGuestExploreAllNewsletterBrands(orderOpt: orderOpt, industry: industry, day: day))
        return response.map { $0.toDomain() }
    }

    public func fetchRecommendation() async throws -> ExploreRecommendedNewsletter {
        async let unionTask = network.request(FetchExploreRecommendUnion())
        async let intersectionTask = network.request(FetchExploreRecommendIntersection())

        let union = try await unionTask
        let intersection = try await intersectionTask

        let dto = ExploreRecommendedNewsletterDTO(union: union, intersection: intersection)
        return dto.toDomain()
    }

    public func fetchOptionList() async throws -> ExploreOptionList {
        let response = try await network.request(FetchExploreOptionList())
        return response.toDomain()
    }
}
