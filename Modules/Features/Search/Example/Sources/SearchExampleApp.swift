import SwiftUI
import Shared
import DesignSystem
import Search
import SearchDomain
import SearchTesting

@main
struct SearchExampleApp: App {
    @State private var router = AppRouter()
    @State private var tabSelection = TabSelection()

    init() {
        AppState.shared.login()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SearchView(viewModel: makeViewModel())
            }
            .environment(router)
            .environment(tabSelection)
            .environment(AppState.shared)
            .environment(ToastCenter.shared)
        }
    }

    @MainActor
    private func makeViewModel() -> SearchViewModel {
        let search = MockSearchNewslettersUseCase()
        search.result = .success(SampleSearchedNewsletters.mixed)

        let popular = MockFetchPopularKeywordsUseCase()
        popular.result = .success(SamplePopularKeywords.mixed)

        return SearchViewModel(
            searchNewslettersUseCase: search,
            fetchPopularKeywordsUseCase: popular
        )
    }
}
