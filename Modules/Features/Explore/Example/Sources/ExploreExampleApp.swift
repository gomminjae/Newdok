import SwiftUI
import Shared
import DesignSystem
import Explore
import ExploreDomain
import ExploreTesting

@main
struct ExploreExampleApp: App {
    init() {
        AppState.shared.login()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ExploreView(
                    viewModel: makeViewModel(),
                    landing: nil,
                    onSearch: {},
                    onSignup: {},
                    onLogin: {},
                    onEditProfile: {},
                    onBrandTap: { _ in }
                )
            }
            .environment(AppState.shared)
            .environment(ToastCenter.shared)
        }
    }

    @MainActor
    private func makeViewModel() -> ExploreViewModel {
        let newsletters = MockFetchExploreNewslettersUseCase()
        newsletters.result = .success(SampleExploreBrands.mixed)

        let guestNewsletters = MockFetchGuestExploreNewslettersUseCase()
        guestNewsletters.result = .success(SampleExploreBrands.mixed)

        let recommendation = MockFetchExploreRecommendationUseCase()
        recommendation.result = .success(SampleExploreRecommendations.mixed)

        return ExploreViewModel(
            fetchNewslettersUseCase: newsletters,
            fetchGuestNewslettersUseCase: guestNewsletters,
            fetchRecommendationUseCase: recommendation,
            transformRecommendationUseCase: TransformExploreRecommendationUseCaseImpl(),
            prioritizeInterestsUseCase: PrioritizeInterestsUseCaseImpl(),
            userInfoStore: UserInfoStore.shared,
            selectableItemStore: SelectableItemStore.shared
        )
    }
}
