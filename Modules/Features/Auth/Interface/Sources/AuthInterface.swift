import SwiftUI
import Shared

@MainActor
public protocol AuthBuildable {
    func makeOnboardingView(
        context: AuthAnalyticsContext,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void
    ) -> AnyView

    func makeLoginView(
        context: AuthAnalyticsContext,
        canGoBack: Bool,
        onBack: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onNeedSignup: @escaping (String, String?) -> Void,
        onAuthenticated: @escaping () -> Void
    ) -> AnyView

    func makeSignupView(
        context: AuthAnalyticsContext,
        signupToken: String,
        nickname: String?,
        onBack: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onAuthenticated: @escaping () -> Void
    ) -> AnyView

    func signOut() async
}
