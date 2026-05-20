import SwiftUI
import Shared
import DesignSystem
import Explore
import ExploreDomain
import ExploreTesting

@main
struct ExploreExampleApp: App {
    @State private var router = AppRouter()
    @State private var tabSelection = TabSelection()

    init() {
        AppState.shared.login()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ExploreView(viewModel: makeViewModel())
            }
            .environment(router)
            .environment(tabSelection)
            .environment(AppState.shared)
            .environment(ToastCenter.shared)
        }
    }

    @MainActor
    private func makeViewModel() -> ExploreViewModel {
        let newsletters = MockFetchExploreNewslettersUseCase()
        newsletters.result = .success(SampleExploreBrands.mixed)

        let brandDetail = MockFetchExploreBrandDetailUseCase()

        let guestNewsletters = MockFetchGuestExploreNewslettersUseCase()
        guestNewsletters.result = .success(SampleExploreBrands.mixed)

        let recommendation = MockFetchExploreRecommendationUseCase()
        recommendation.result = .success(SampleExploreRecommendations.mixed)

        return ExploreViewModel(
            fetchNewslettersUseCase: newsletters,
            fetchBrandDetailUseCase: brandDetail,
            fetchGuestNewslettersUseCase: guestNewsletters,
            fetchRecommendationUseCase: recommendation
        )
    }
}
