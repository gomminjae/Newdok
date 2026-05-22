import SwiftUI
import Core
import BookmarkInterface
import BookmarkDomain
import BookmarkData

public struct BookmarkBuilder: BookmarkBuildable {
    private let network: any NetworkService<ArticleAPI>

    public init(network: any NetworkService<ArticleAPI>) {
        self.network = network
    }

    public func makeBookmarkView() -> AnyView {
        let repository = BookmarkRepositoryImpl(network: network)
        let viewModel = BookmarkViewModel(
            fetchArticlesUseCase: FetchBookmarkedArticlesUseCaseImpl(repository: repository),
            toggleBookmarkUseCase: ToggleBookmarkStatusUseCaseImpl(repository: repository),
            fetchInterestsUseCase: FetchBookmarkedInterestsUseCaseImpl(repository: repository)
        )
        return AnyView(BookmarkView(viewModel: viewModel))
    }
}
