import ExploreDomain
import Core
import Shared
import Moya

public class ExploreNewsletterRepositoryImpl: ExploreNewsletterRepository {
    private let provider: MoyaProvider<NewsletterAPI>

    public init(provider: MoyaProvider<NewsletterAPI>) {
        self.provider = provider
    }

    public func fetchNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand] {
        let response: [ExploreBrandDTO] = try await provider.asyncRequest(.fetchAllNewsletterBrands(orderOpt: orderOpt, industry: industry, day: day))
        return response.map { $0.toDomain() }
    }

    public func fetchNewsletterBrand(id: String) async throws -> ExploreBrandDetail {
        let response: ExploreBrandDetailDTO = try await provider.asyncRequest(.fetchNewsletterBrand(id: id))
        return response.toDomain()
    }

    public func fetchGuestAllNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [ExploreBrand] {
        let response: [ExploreBrandDTO] = try await provider.asyncRequest(.fetchGuestAllNewsletterBrand(orderOpt: orderOpt, industry: industry, day: day))
        return response.map { $0.toDomain() }
    }

    public func fetchGuestNewsletterBrand(id: String) async throws -> ExploreBrandDetail {
        let response: ExploreBrandDetailDTO = try await provider.asyncRequest(.fetchGuestNewsletterBrand(id: id))
        return response.toDomain()
    }

    public func fetchRecommendation() async throws -> ExploreRecommendedNewsletter {
        async let unionTask: [ExploreNewsletterDetailDTO] = provider.asyncRequest(.fetchRecommendUnion)
        async let intersectionTask: [ExploreNewsletterDetailDTO] = provider.asyncRequest(.fetchRecommendIntersection)

        let union = try await unionTask
        let intersection = try await intersectionTask

        let dto = ExploreRecommendedNewsletterDTO(union: union, intersection: intersection)
        return dto.toDomain()
    }

    public func fetchOptionList() async throws -> ExploreOptionList {
        let response: ExploreOptionListDTO = try await provider.asyncRequest(.fetchOptionList)
        return response.toDomain()
    }
}
