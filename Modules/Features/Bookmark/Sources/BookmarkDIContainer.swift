import Shared
import NetworkKit
import BookmarkDomain
import BookmarkData

struct BookmarkDIContainer {
    private let analytics: AnalyticsClient
    private let network: any NetworkService

    init(networkProvider: NetworkProviding, analytics: AnalyticsClient) {
        self.analytics = analytics
        self.network = networkProvider.makeService()
    }

    // MARK: - Repository

    func makeRepository() -> BookmarkRepository {
        BookmarkRepositoryImpl(network: network)
    }

    // MARK: - UseCases

    func makeFetchArticlesUseCase(repository: BookmarkRepository) -> FetchBookmarkedArticlesUseCase {
        FetchBookmarkedArticlesUseCaseImpl(repository: repository)
    }

    func makeFetchInterestsUseCase(repository: BookmarkRepository) -> FetchBookmarkedInterestsUseCase {
        FetchBookmarkedInterestsUseCaseImpl(repository: repository)
    }

    // MARK: - ViewModel

    @MainActor
    func makeViewModel() -> BookmarkViewModel {
        let repository = makeRepository()
        return BookmarkViewModel(
            fetchArticlesUseCase: makeFetchArticlesUseCase(repository: repository),
            fetchInterestsUseCase: makeFetchInterestsUseCase(repository: repository),
            analytics: analytics
        )
    }
}
