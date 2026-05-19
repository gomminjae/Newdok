import SubscribeDomain

public final class ResumeSubscriptionUseCaseImpl: ResumeSubscriptionUseCase {
    private let repository: SubscribeNewsletterRepository

    public init(repository: SubscribeNewsletterRepository) {
        self.repository = repository
    }

    public func execute(newsletterId: String) async throws {
        try await repository.resumeSubscription(newsletterId: newsletterId)
    }
}
