import SubscribeDomain
import NetworkKit

public final class SubscribeNewsletterRepositoryImpl: SubscribeNewsletterRepository {
    private let network: any NetworkService

    public init(network: any NetworkService) {
        self.network = network
    }

    public func fetchActiveSubscription() async throws -> [SubscribeNewsletter] {
        let response = try await network.request(FetchActiveNewsletters())
        return response.map { $0.toDomain() }
    }

    public func fetchPausedSubscription() async throws -> [SubscribeNewsletter] {
        let response = try await network.request(FetchPausedNewsletters())
        return response.map { $0.toDomain() }
    }

    public func pauseSubscription(newsletterId: String) async throws {
        do {
            try await network.requestVoid(PauseSubscription(newsletterId: newsletterId))
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error, statusCode == 400 {
                throw SubscribeError.alreadyPaused
            }
            throw error
        }
    }

    public func resumeSubscription(newsletterId: String) async throws {
        do {
            try await network.requestVoid(ResumeSubscription(newsletterId: newsletterId))
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error, statusCode == 400 {
                throw SubscribeError.alreadyActive
            }
            throw error
        }
    }

    public func fetchSubscriptionCount() async throws -> Int {
        let response = try await network.request(FetchSubscriptionCount())
        return response.count
    }
}
