import SwiftUI

struct AuthFlow: View {
    let container: AppContainer
    let appRouter: AppRouter
    let root: AuthRoute

    @State private var path: [AuthRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
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
                onSignup: { path.append(.login) },
                onLogin: { path.append(.login) }
            )
        case .login:
            container.makeLoginView(
                canGoBack: !path.isEmpty,
                onBack: { _ = path.popLast() },
                onSignup: { path.append(.login) },
                onNeedSignup: { token, nickname in
                    path.append(.signup(signupToken: token, nickname: nickname))
                },
                onAuthenticated: { appRouter.finishAuthentication() }
            )
        case let .signup(token, nickname):
            container.makeSignupView(
                signupToken: token,
                nickname: nickname,
                onBack: { _ = path.popLast() },
                onLogin: { path.append(.login) },
                onAuthenticated: { appRouter.finishAuthentication() }
            )
        }
    }
}
