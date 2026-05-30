import Core
import AuthDomain
import AuthData

@MainActor
final class AuthDIContainer {
    private let network: any NetworkService<AuthUserAPI>

    init(networkProvider: NetworkProviding) {
        self.network = networkProvider.makeService(for: AuthUserAPI.self)
    }

    func makeRepository() -> AuthRepository {
        AuthRepositoryImpl(network: network)
    }

    func makeLoginViewModel() -> LoginViewModel {
        let repository = makeRepository()
        return LoginViewModel(loginUseCase: LoginUseCaseImpl(authRepository: repository))
    }

    func makeSignupViewModel() -> SignupViewModel {
        let repository = makeRepository()
        return SignupViewModel(
            authRepository: repository,
            signupUseCase: SignupUseCaseImpl(authRepository: repository)
        )
    }

    func signOut() async {
        await makeRepository().signOut()
    }
}
