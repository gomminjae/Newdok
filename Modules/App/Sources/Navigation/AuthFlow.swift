import SwiftUI
import Shared

struct AuthFlow: View {
    let container: AppContainer
    let appRouter: AppRouter
    let root: AuthRoute

    @State private var context: AuthAnalyticsContext
    @State private var path: [AuthRoute] = []

    init(container: AppContainer, appRouter: AppRouter, root: AuthRoute) {
        self.container = container
        self.appRouter = appRouter
        self.root = root
        _context = State(initialValue: AuthAnalyticsContext(entryPoint: root == .onboarding ? .onboarding : appRouter.analyticsEntryPoint))
    }

    var body: some View {
        NavigationStack(path: $path) {
            routeView(root)
                .analyticsVisibility(path.isEmpty)
                .navigationDestination(for: AuthRoute.self) { route in
                    routeView(route)
                        .analyticsVisibility(path.last == route)
                }
        }
        .onChange(of: path) { old, new in
            if old.last == .login && new.last != .login { context.invalidate() }
        }
    }

    @ViewBuilder
    private func routeView(_ route: AuthRoute) -> some View {
        switch route {
        case .onboarding:
            // 소셜 로그인: 직접 회원가입 진입 없음 — 회원가입 버튼도 로그인 화면으로
            container.makeOnboardingView(
                context: context,
                onSignup: { path.append(.login) },
                onLogin: { path.append(.login) }
            )
        case .login:
            container.makeLoginView(
                context: context,
                canGoBack: !path.isEmpty,
                onBack: { context.invalidate(); _ = path.popLast() },
                onSignup: { path.append(.login) },
                onNeedSignup: { token, nickname in
                    path.append(.signup(signupToken: token, nickname: nickname))
                },
                onAuthenticated: { appRouter.finishAuthentication(flowID: context.flowID, from: .login) }
            )
        case let .signup(token, nickname):
            container.makeSignupView(
                context: context,
                signupToken: token,
                nickname: nickname,
                onBack: { context.invalidate(); _ = path.popLast() },
                onLogin: { path.append(.login) },
                onAuthenticated: { appRouter.finishAuthentication(flowID: context.flowID, from: .signup) }
            )
        }
    }
}
