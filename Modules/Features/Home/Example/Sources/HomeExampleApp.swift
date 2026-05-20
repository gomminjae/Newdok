import SwiftUI
import Shared
import DesignSystem
import Home
import HomeDomain
import HomeTesting

@main
struct HomeExampleApp: App {
    @State private var router = AppRouter()
    @State private var tabSelection = TabSelection()

    init() {
        AppState.shared.login()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView(viewModel: makeViewModel())
            }
            .environment(router)
            .environment(tabSelection)
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
            fetchHighlightCounts: highlights,
            refreshArticles: MockRefreshHomeArticlesUseCase(),
            loadReadIds: MockLoadReadArticleIdsUseCase(),
            saveReadIds: MockSaveReadArticleIdsUseCase(),
            appState: AppState.shared
        )
    }
}
