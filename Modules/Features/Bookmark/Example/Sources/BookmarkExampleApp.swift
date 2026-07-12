import SwiftUI
import Shared
import DesignSystem
import Bookmark
import BookmarkDomain
import BookmarkTesting

@main
struct BookmarkExampleApp: App {
    init() {
        AppState.shared.login()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                BookmarkView(
                    viewModel: makeViewModel(),
                    onSearch: {},
                    onLogin: {},
                    onArticleTap: { _ in }
                )
            }
            .environment(AppState.shared)
            .environment(ToastCenter.shared)
        }
    }

    @MainActor
    private func makeViewModel() -> BookmarkViewModel {
        let articles = MockFetchBookmarkedArticlesUseCase()
        articles.result = .success(SampleBookmarkedArticles.mixed)

        let interests = MockFetchBookmarkedInterestsUseCase()
        interests.result = .success(SampleBookmarkInterests.mixed)

        return BookmarkViewModel(
            fetchArticlesUseCase: articles,
            fetchInterestsUseCase: interests
        )
    }
}
