import SubscribeDomain

public final class FetchPausedSubscriptionUseCaseImpl: FetchPausedSubscriptionUseCase {
    private let repository: SubscribeNewsletterRepository

    public init(repository: SubscribeNewsletterRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [SubscribeNewsletter] {
        try await repository.fetchPausedSubscription()
    }
}
