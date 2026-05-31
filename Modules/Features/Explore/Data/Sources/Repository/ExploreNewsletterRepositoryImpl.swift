import ExploreDomain
import Core
import Shared

public final class ExploreNewsletterRepositoryImpl: ExploreNewsletterRepository {
    private let network: any NetworkService<ExploreNewsletterAPI>

    public init(network: any NetworkService<ExploreNewsletterAPI>) {
        self.network = network
    }

    public func fetchNewsletters(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand] {
        let response: [ExploreBrandDTO] = try await network.request(.fetchAllNewsletterBrands(orderOpt: orderOpt, industry: industry, day: day))
        return response.map { $0.toDomain() }
    }

    public func fetchNewsletterBrand(id: String) async throws -> ExploreBrandDetail {
        let response: ExploreBrandDetailDTO = try await network.request(.fetchNewsletterBrand(id: id))
        return response.toDomain()
    }

    public func fetchGuestAllNewsletters(orderOpt: ExploreOrderOption, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand] {
        let response: [ExploreBrandDTO] = try await network.request(.fetchGuestAllNewsletterBrand(orderOpt: orderOpt, industry: industry, day: day))
        return response.map { $0.toDomain() }
    }

    public func fetchGuestNewsletterBrand(id: String) async throws -> ExploreBrandDetail {
        let response: ExploreBrandDetailDTO = try await network.request(.fetchGuestNewsletterBrand(id: id))
        return response.toDomain()
    }

    public func fetchRecommendation() async throws -> ExploreRecommendedNewsletter {
        async let unionTask: [ExploreNewsletterDetailDTO] = network.request(.fetchRecommendUnion)
        async let intersectionTask: [ExploreNewsletterDetailDTO] = network.request(.fetchRecommendIntersection)

        let union = try await unionTask
        let intersection = try await intersectionTask

        let dto = ExploreRecommendedNewsletterDTO(union: union, intersection: intersection)
        return dto.toDomain()
    }

    public func fetchOptionList() async throws -> ExploreOptionList {
        let response: ExploreOptionListDTO = try await network.request(.fetchOptionList)
        return response.toDomain()
    }
}
