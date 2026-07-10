import SwiftUI
import Shared
import DesignSystem
import Home
import HomeDomain
import HomeTesting

@main
struct HomeExampleApp: App {
    init() {
        AppState.shared.login()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView(
                    viewModel: makeViewModel(),
                    onArticleTap: { _ in },
                    onSearch: {},
                    onSignup: {},
                    onLogin: {},
                    onGoToExplore: { _, _ in }
                )
            }
            .environment(AppState.shared)
            .environment(ToastCenter.shared)
        }
    }

    @MainActor
    private func makeViewModel() -> HomeViewModel {
        let today = MockFetchTodayArticlesUseCase()
        today.result = .success(SampleHomeArticles.mixed)

        let month = MockFetchMonthArticlesUseCase()
        month.result = .success(SampleHomeMonthArticles.currentMonth)

        let day = MockFetchDayArticlesUseCase()
        day.result = .success(SampleHomeArticles.mixed)

        let newsletters = MockFetchHomeNewslettersUseCase()
        newsletters.result = .success(SampleHomeNewsletters.mixed)

        let highlights = MockFetchHomeHighlightCountsUseCase()
        highlights.result = [1001: 3, 1002: 1, 1004: 2, 1005: 4]

        return HomeViewModel(
            fetchTodayArticles: today,
            fetchMonthArticles: month,
            fetchDayArticles: day,
            fetchNewsletters: newsletters,
            decorateArticles: DecorateArticlesUseCaseImpl(highlightCountsUseCase: highlights),
            refreshArticles: MockRefreshHomeArticlesUseCase(),
            loadReadIds: MockLoadReadArticleIdsUseCase(),
            saveReadIds: MockSaveReadArticleIdsUseCase(),
            extractArticleDays: ExtractArticleDaysUseCaseImpl(),
            mergeDayArticleSummary: MergeDayArticleSummaryUseCaseImpl(),
            appState: AppState.shared
        )
    }
}
