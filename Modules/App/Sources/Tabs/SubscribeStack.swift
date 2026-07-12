import SwiftUI
import DesignSystem

struct SubscribeStack: View {
    let container: AppContainer
    let coordinator: AppCoordinator

    var body: some View {
        @Bindable var router = coordinator.subscribeRouter
        NavigationStack(path: $router.path) {
            container.makeSubscribeView(
                onSearch: { coordinator.subscribeRouter.push(.search) },
                onLogin: { coordinator.presentAuth(.login) },
                onBrandTap: { coordinator.subscribeRouter.push(.brandDetail(id: $0)) }
            )
            .navigationDestination(for: SubscribeRoute.self) { route in
                destination(route)
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: SubscribeRoute) -> some View {
        switch route {
        case .search:
            container.makeSearchView(
                onBack: { coordinator.subscribeRouter.pop() },
                onBrandTap: { coordinator.subscribeRouter.push(.brandDetail(id: $0)) },
                onFeedback: { coordinator.subscribeRouter.push(.feedback) }
            )
        case let .brandDetail(id):
            container.makeBrandDetailView(
                id: id,
                onBack: { coordinator.subscribeRouter.pop() },
                onSignup: { coordinator.presentAuth(.login) },
                onGoHome: { coordinator.goHome() },
                onArticleTap: { coordinator.subscribeRouter.push(.articleDetail(id: $0, isPast: true)) }
            )
            .enableSwipeBack()
        case let .articleDetail(id, isPast):
            container.makeArticleDetailView(id: id, isPast: isPast, onBack: { coordinator.subscribeRouter.pop() })
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        case .feedback:
            container.makeFeedbackView(onBack: { coordinator.subscribeRouter.pop() })
        }
    }
}
