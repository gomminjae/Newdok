import SubscribeDomain

public final class FetchActiveSubscriptionUseCaseImpl: FetchActiveSubscriptionUseCase {
    private let repository: SubscribeNewsletterRepository

    public init(repository: SubscribeNewsletterRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [SubscribeNewsletter] {
        try await repository.fetchActiveSubscription()
    }
}
