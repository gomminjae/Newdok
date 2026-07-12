import SwiftUI

@MainActor
public protocol AuthBuildable {
    func makeOnboardingView(
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void
    ) -> AnyView

    func makeLoginView(
        canGoBack: Bool,
        onBack: @escaping () -> Void,
        onRecovery: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onAuthenticated: @escaping () -> Void
    ) -> AnyView

    func makeSignupView(
        onBack: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onRecovery: @escaping () -> Void,
        onAuthenticated: @escaping () -> Void
    ) -> AnyView

    func signOut() async
}
