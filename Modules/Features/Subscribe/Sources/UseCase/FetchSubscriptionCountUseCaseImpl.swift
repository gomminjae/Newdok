import SubscribeDomain

public final class FetchSubscriptionCountUseCaseImpl: FetchSubscriptionCountUseCase {
    private let repository: SubscribeNewsletterRepository

    public init(repository: SubscribeNewsletterRepository) {
        self.repository = repository
    }

    public func execute() async throws -> Int {
        try await repository.fetchSubscriptionCount()
    }
}
