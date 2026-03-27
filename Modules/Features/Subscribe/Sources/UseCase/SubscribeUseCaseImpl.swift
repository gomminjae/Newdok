import SubscribeDomain

public final class SubscribeUseCaseImpl: SubscribeUseCase {
    private let repository: SubscribeNewsletterRepository

    public init(repository: SubscribeNewsletterRepository) {
        self.repository = repository
    }

    public func fetchActiveSubscription() async throws -> [SubscribeNewsletter] {
        return try await repository.fetchActiveSubscription()
    }

    public func fetchPausedSubscription() async throws -> [SubscribeNewsletter] {
        return try await repository.fetchPausedSubscription()
    }

    public func pauseSubscription(newsletterId: String) async throws {
        try await repository.pauseSubscription(newsletterId: newsletterId)
    }

    public func resumeSubscription(newsletterId: String) async throws {
        try await repository.resumeSubscription(newsletterId: newsletterId)
    }

    public func fetchSubscriptionCount() async throws -> Int {
        return try await repository.fetchSubscriptionCount()
    }
}
