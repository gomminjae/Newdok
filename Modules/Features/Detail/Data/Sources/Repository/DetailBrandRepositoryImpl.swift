import DetailDomain
import NetworkKit
import Shared

public final class DetailBrandRepositoryImpl: DetailBrandRepository {
    private let network: any NetworkService

    public init(network: any NetworkService) {
        self.network = network
    }

    public func fetchNewsletterBrand(id: String) async throws -> DetailBrandDetail {
        logDebug("브랜드 상세 조회 - ID: \(id)", category: .repository)
        let response = try await network.request(FetchNewsletterBrand(id: id))
        logDebug("브랜드 상세 조회 완료", category: .repository)
        return response.toDomain()
    }

    public func fetchGuestNewsletterBrand(id: String) async throws -> DetailBrandDetail {
        let response = try await network.request(FetchGuestNewsletterBrand(id: id))
        return response.toDomain()
    }

    public func pauseSubscription(newsletterId: String) async throws {
        do {
            try await network.requestVoid(PauseNewsletterSubscription(newsletterId: newsletterId))
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error, statusCode == 400 {
                throw DetailError.alreadyPaused
            }
            throw error
        }
    }

    public func resumeSubscription(newsletterId: String) async throws {
        do {
            try await network.requestVoid(ResumeNewsletterSubscription(newsletterId: newsletterId))
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error, statusCode == 400 {
                throw DetailError.alreadyActive
            }
            throw error
        }
    }
}
