import SwiftUI
import Core
import BookmarkInterface
import BookmarkDomain
import BookmarkData

public struct BookmarkBuilder: BookmarkBuildable {
    private let network: any NetworkService<BookmarkArticleAPI>

    public init(networkProvider: NetworkProviding) {
        self.network = BookmarkNetworkFactory.makeArticleNetwork(networkProvider)
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
