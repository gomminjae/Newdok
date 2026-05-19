import SubscribeDomain

public final class PauseSubscriptionUseCaseImpl: PauseSubscriptionUseCase {
    private let repository: SubscribeNewsletterRepository

    public init(repository: SubscribeNewsletterRepository) {
        self.repository = repository
    }

    public func execute(newsletterId: String) async throws {
        try await repository.pauseSubscription(newsletterId: newsletterId)
    }
}
