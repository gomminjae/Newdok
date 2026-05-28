import SwiftUI
import Core
import AuthInterface
import AuthDomain
import AuthData

public struct AuthBuilder: AuthBuildable {
    private let network: any NetworkService<AuthUserAPI>

    public init(networkProvider: NetworkProviding) {
        self.network = AuthNetworkFactory.makeUserNetwork(networkProvider)
    }

    public func makeOnboardingView() -> AnyView {
        AnyView(OnboardingView())
    }

    public func makeLoginView() -> AnyView {
        let repository = AuthRepositoryImpl(network: network)
        let viewModel = LoginViewModel(loginUseCase: LoginUseCaseImpl(authRepository: repository))
        return AnyView(LoginView(viewModel: viewModel))
    }

    public func makeSignupView() -> AnyView {
        let repository = AuthRepositoryImpl(network: network)
        let viewModel = SignupViewModel(
            authRepository: repository,
            signupUseCase: SignupUseCaseImpl(authRepository: repository)
        )
        return AnyView(SignupView(viewModel: viewModel))
    }

    public func signOut() async {
        await AuthRepositoryImpl(network: network).signOut()
    }
}
