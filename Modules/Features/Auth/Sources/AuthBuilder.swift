import SwiftUI
import Core
import AuthInterface

public struct AuthBuilder: AuthBuildable {
    private let container: AuthDIContainer

    public init(networkProvider: NetworkProviding) {
        self.container = AuthDIContainer(networkProvider: networkProvider)
    }

    public func makeOnboardingView() -> AnyView {
        AnyView(OnboardingView())
    }

    public func makeLoginView() -> AnyView {
        AnyView(LoginView(viewModel: container.makeLoginViewModel()))
    }

    public func makeSignupView() -> AnyView {
        AnyView(SignupView(viewModel: container.makeSignupViewModel()))
    }

    public func signOut() async {
        await container.signOut()
    }
}
