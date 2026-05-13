import SubscribeDomain
import Core

public final class SubscribeNewsletterRepositoryImpl: SubscribeNewsletterRepository {
    private let network: any NetworkService<NewsletterAPI>

    public init(network: any NetworkService<NewsletterAPI>) {
        self.network = network
    }

    public func fetchActiveSubscription() async throws -> [SubscribeNewsletter] {
        let response: [SubscribeNewsletterDTO] = try await network.request(.fetchActiveNewletters)
        return response.map { $0.toDomain() }
    }

    public func fetchPausedSubscription() async throws -> [SubscribeNewsletter] {
        let response: [SubscribeNewsletterDTO] = try await network.request(.fetchPausedNewletters)
        return response.map { $0.toDomain() }
    }

    public func pauseSubscription(newsletterId: String) async throws {
        try await network.requestVoid(.pauseSubscription(newsletterId: newsletterId))
    }

    public func resumeSubscription(newsletterId: String) async throws {
        try await network.requestVoid(.resumeSubscription(newsletterId: newsletterId))
    }

    public func fetchSubscriptionCount() async throws -> Int {
        let response: SubscribeNewslettersCountDTO = try await network.request(.fetchSubscriptionCount)
        return response.count
    }
}
