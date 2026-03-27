import SwiftUI
import AuthInterface
import AuthDomain
import DesignSystem
import Shared

public struct AuthViewFactoryImpl: AuthViewFactory {
    private let signupViewModelProvider: @MainActor () -> SignupViewModel
    private let loginViewModelProvider: @MainActor () -> LoginViewModel

    public init(
        signupViewModelProvider: @MainActor @escaping () -> SignupViewModel,
        loginViewModelProvider: @MainActor @escaping () -> LoginViewModel
    ) {
        self.signupViewModelProvider = signupViewModelProvider
        self.loginViewModelProvider = loginViewModelProvider
    }

    @MainActor public func makeSignupView() -> AnyView {
        let vm = signupViewModelProvider()
        return AnyView(SignupView(viewModel: vm))
    }

    @MainActor public func makeLoginView() -> AnyView {
        let vm = loginViewModelProvider()
        return AnyView(LoginView(viewModel: vm))
    }

    @MainActor public func makeOnboardingView() -> AnyView {
        return AnyView(OnboardingView())
    }
}
