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
            // 소셜 로그인: 직접 회원가입 진입 없음 — 회원가입 버튼도 로그인 화면으로
            container.makeOnboardingView(
                onSignup: { router.push(.login) },
                onLogin: { router.push(.login) }
            )
        case .login:
            container.makeLoginView(
                canGoBack: !router.path.isEmpty,
                onBack: { router.pop() },
                onRecovery: { router.push(.recovery) },
                onSignup: { router.push(.login) },
                onNeedSignup: { token, nickname in
                    router.push(.signup(signupToken: token, nickname: nickname))
                },
                onAuthenticated: { coordinator.finishAuth() }
            )
        case let .signup(token, nickname):
            container.makeSignupView(
                signupToken: token,
                nickname: nickname,
                onBack: { router.pop() },
                onLogin: { router.push(.login) },
                onRecovery: { router.push(.recovery) },
                onAuthenticated: { coordinator.finishAuth() }
            )
        case .recovery:
            container.makeRecoveryView(
                onBack: { router.pop() },
                onSignup: { router.push(.login) },
                onLogin: { router.push(.login) },
                onServiceFeedback: { router.push(.serviceFeedback) }
            )
        case .serviceFeedback:
            container.makeFeedbackView(onBack: { router.pop() })
        }
    }
}
