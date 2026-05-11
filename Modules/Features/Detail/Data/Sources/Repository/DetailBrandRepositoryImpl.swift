import DetailDomain
import Core
import Shared

public final class DetailBrandRepositoryImpl: DetailBrandRepository {
    private let network: any NetworkService<NewsletterAPI>

    public init(network: any NetworkService<NewsletterAPI>) {
        self.network = network
    }

    public func fetchNewsletterBrand(id: String) async throws -> DetailBrandDetail {
        logDebug("브랜드 상세 조회 - ID: \(id)", category: .repository)
        let response: DetailBrandDetailDTO = try await network.request(.fetchNewsletterBrand(id: id))
        logDebug("브랜드 상세 조회 완료", category: .repository)
        return response.toDomain()
    }

    public func fetchGuestNewsletterBrand(id: String) async throws -> DetailBrandDetail {
        let response: DetailBrandDetailDTO = try await network.request(.fetchGuestNewsletterBrand(id: id))
        return response.toDomain()
    }

    public func pauseSubscription(newsletterId: String) async throws {
        try await network.requestVoid(.pauseSubscription(newsletterId: newsletterId))
    }

    public func resumeSubscription(newsletterId: String) async throws {
        try await network.requestVoid(.resumeSubscription(newsletterId: newsletterId))
    }
}
