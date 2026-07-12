import SwiftUI

struct AuthFlow: View {
    let container: AppContainer
    let coordinator: AppCoordinator
    let root: AuthRoute

    @State private var router = Router<AuthRoute>()

    var body: some View {
        NavigationStack(path: $router.path) {
            routeView(root)
                .navigationDestination(for: AuthRoute.self) { route in
                    routeView(route)
                }
        }
    }

    @ViewBuilder
    private func routeView(_ route: AuthRoute) -> some View {
        switch route {
        case .onboarding:
            container.makeOnboardingView(
                onSignup: { router.push(.signup) },
                onLogin: { router.push(.login) }
            )
        case .login:
            container.makeLoginView(
                canGoBack: !router.path.isEmpty,
                onBack: { router.pop() },
                onRecovery: { router.push(.recovery) },
                onSignup: { router.push(.signup) },
                onAuthenticated: { coordinator.finishAuth() }
            )
        case .signup:
            container.makeSignupView(
                onBack: { router.pop() },
                onLogin: { router.push(.login) },
                onRecovery: { router.push(.recovery) },
                onAuthenticated: { coordinator.finishAuth() }
            )
        case .recovery:
            container.makeRecoveryView(
                onBack: { router.pop() },
                onSignup: { router.push(.signup) },
                onLogin: { router.push(.login) },
                onServiceFeedback: { router.push(.serviceFeedback) }
            )
        case .serviceFeedback:
            container.makeFeedbackView(onBack: { router.pop() })
        }
    }
}
