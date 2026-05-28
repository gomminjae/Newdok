import DetailDomain
import Core
import Shared

public final class DetailBrandRepositoryImpl: DetailBrandRepository {
    private let network: any NetworkService<DetailNewsletterAPI>

    public init(network: any NetworkService<DetailNewsletterAPI>) {
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
        do {
            try await network.requestVoid(.pauseSubscription(newsletterId: newsletterId))
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error, statusCode == 400 {
                throw DetailError.alreadyPaused
            }
            throw error
        }
    }

    public func resumeSubscription(newsletterId: String) async throws {
        do {
            try await network.requestVoid(.resumeSubscription(newsletterId: newsletterId))
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error, statusCode == 400 {
                throw DetailError.alreadyActive
            }
            throw error
        }
    }
}
