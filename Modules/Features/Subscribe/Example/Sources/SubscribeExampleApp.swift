import SwiftUI
import Shared
import DesignSystem
import Subscribe
import SubscribeDomain
import SubscribeTesting

@main
struct SubscribeExampleApp: App {
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SubscribeView(viewModel: makeViewModel())
            }
            .environment(router)
            .environment(AppState.shared)
            .environment(ToastCenter.shared)
        }
    }

    @MainActor
    private func makeViewModel() -> SubscribeViewModel {
        let active = MockFetchActiveSubscriptionUseCase()
        active.result = .success(SampleSubscriptions.mixed)

        let paused = MockFetchPausedSubscriptionUseCase()
        paused.result = .success(SampleSubscriptions.paused)

        return SubscribeViewModel(
            fetchActiveUseCase: active,
            fetchPausedUseCase: paused,
            pauseUseCase: MockPauseSubscriptionUseCase(),
            resumeUseCase: MockResumeSubscriptionUseCase()
        )
    }
}
