import NetworkKit
import Shared
import AuthDomain
import AuthData

@MainActor
final class AuthDIContainer {
    private let network: any NetworkService
    private let tokenStorage: TokenStorageProtocol
    private let userInfoStore: UserInfoStoreProtocol
    private let selectableItemStore: SelectableItemStoreProtocol
    private let appState: AppState

    init(
        networkProvider: NetworkProviding,
        tokenStorage: TokenStorageProtocol = TokenStore.shared,
        userInfoStore: UserInfoStoreProtocol = UserInfoStore.shared,
        selectableItemStore: SelectableItemStoreProtocol = SelectableItemStore.shared,
        appState: AppState = .shared
    ) {
        self.network = networkProvider.makeService()
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
        self.selectableItemStore = selectableItemStore
        self.appState = appState
    }

    func makeRepository() -> AuthRepository {
        AuthRepositoryImpl(network: network, tokenStorage: tokenStorage, userInfoStore: userInfoStore)
    }

    func makeLoginViewModel() -> LoginViewModel {
        let repository = makeRepository()
        return LoginViewModel(
            loginUseCase: LoginUseCaseImpl(authRepository: repository),
            tokenStorage: tokenStorage,
            appState: appState
        )
    }

    func makeSignupViewModel() -> SignupViewModel {
        let repository = makeRepository()
        return SignupViewModel(
            authRepository: repository,
            signupUseCase: SignupUseCaseImpl(authRepository: repository),
            userInfoStore: userInfoStore,
            selectableItemStore: selectableItemStore,
            appState: appState
        )
    }

    func signOut() async {
        await makeRepository().signOut()
    }
}
