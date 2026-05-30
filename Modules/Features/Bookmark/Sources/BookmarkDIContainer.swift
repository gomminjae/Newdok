import Core
import BookmarkDomain
import BookmarkData

struct BookmarkDIContainer {
    private let network: any NetworkService<BookmarkArticleAPI>

    init(networkProvider: NetworkProviding) {
        self.network = networkProvider.makeService(for: BookmarkArticleAPI.self)
    }

    // MARK: - Repository

    func makeRepository() -> BookmarkRepository {
        BookmarkRepositoryImpl(network: network)
    }

    // MARK: - UseCases

    func makeFetchArticlesUseCase(repository: BookmarkRepository) -> FetchBookmarkedArticlesUseCase {
        FetchBookmarkedArticlesUseCaseImpl(repository: repository)
    }

    func makeToggleBookmarkUseCase(repository: BookmarkRepository) -> ToggleBookmarkStatusUseCase {
        ToggleBookmarkStatusUseCaseImpl(repository: repository)
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
            toggleBookmarkUseCase: makeToggleBookmarkUseCase(repository: repository),
            fetchInterestsUseCase: makeFetchInterestsUseCase(repository: repository)
        )
    }
}
