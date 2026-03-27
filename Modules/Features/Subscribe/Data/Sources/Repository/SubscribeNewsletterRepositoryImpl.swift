import SubscribeDomain
import Core
import Moya

public class SubscribeNewsletterRepositoryImpl: SubscribeNewsletterRepository {
    private let provider: MoyaProvider<NewsletterAPI>

    public init(provider: MoyaProvider<NewsletterAPI>) {
        self.provider = provider
    }

    public func fetchActiveSubscription() async throws -> [SubscribeNewsletter] {
        let response: [SubscribeNewsletterDTO] = try await provider.asyncRequest(.fetchActiveNewletters)
        return response.map { $0.toDomain() }
    }

    public func fetchPausedSubscription() async throws -> [SubscribeNewsletter] {
        let response: [SubscribeNewsletterDTO] = try await provider.asyncRequest(.fetchPausedNewletters)
        return response.map { $0.toDomain() }
    }

    public func pauseSubscription(newsletterId: String) async throws {
        try await provider.asyncVoidRequest(.pauseSubscription(newsletterId: newsletterId))
    }

    public func resumeSubscription(newsletterId: String) async throws {
        try await provider.asyncVoidRequest(.resumeSubscription(newsletterId: newsletterId))
    }

    public func fetchSubscriptionCount() async throws -> Int {
        let response: SubscribeNewslettersCountDTO = try await provider.asyncRequest(.fetchSubscriptionCount)
        return response.count
    }
}
