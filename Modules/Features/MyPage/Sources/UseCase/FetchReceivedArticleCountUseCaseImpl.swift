import MypageDomain

public final class FetchReceivedArticleCountUseCaseImpl: FetchReceivedArticleCountUseCase {
    private let repository: MypageStatsRepository

    public init(repository: MypageStatsRepository) {
        self.repository = repository
    }

    public func execute() async throws -> Int {
        try await repository.fetchReceivedArticleCount()
    }
}
