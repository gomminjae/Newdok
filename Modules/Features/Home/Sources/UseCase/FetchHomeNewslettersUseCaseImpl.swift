import HomeDomain

public final class FetchHomeNewslettersUseCaseImpl: FetchHomeNewslettersUseCase {
    private let repository: HomeNewsletterRepository

    public init(repository: HomeNewsletterRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [HomeNewsletter] {
        try await repository.fetchActiveSubscription()
    }
}
