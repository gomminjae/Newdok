import NetworkKit
import Shared
import AuthDomain
import AuthData

@MainActor
final class AuthDIContainer {
    private let analytics: AnalyticsClient
    private let network: any NetworkService
    private let tokenStorage: TokenStorageProtocol
    private let userInfoStore: UserInfoStoreProtocol
    private let selectableItemStore: SelectableItemStoreProtocol
    private let appState: AppState
    let onboardingStorage: OnboardingStorable

    init(
        networkProvider: NetworkProviding,
        tokenStorage: TokenStorageProtocol,
        userInfoStore: UserInfoStoreProtocol,
        selectableItemStore: SelectableItemStoreProtocol,
        appState: AppState,
        onboardingStorage: OnboardingStorable,
        analytics: AnalyticsClient
    ) {
        self.analytics = analytics
        self.network = networkProvider.makeService()
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
        self.selectableItemStore = selectableItemStore
        self.appState = appState
        self.onboardingStorage = onboardingStorage
    }

    func makeRepository() -> AuthRepository {
        AuthRepositoryImpl(network: network, tokenStorage: tokenStorage, userInfoStore: userInfoStore)
    }

    func makeLoginViewModel(context: AuthAnalyticsContext) -> LoginViewModel {
        let repository = makeRepository()
        return LoginViewModel(
            loginUseCase: LoginUseCaseImpl(authRepository: repository),
            kakaoAuthService: KakaoAuthService(),
            appleAuthService: AppleAuthService(),
            tokenStorage: tokenStorage,
            appState: appState,
            context: context,
            analytics: analytics
        )
    }

    func makeSignupViewModel(context: AuthAnalyticsContext, signupToken: String, nickname: String?) -> SignupViewModel {
        let repository = makeRepository()
        return SignupViewModel(
            signupToken: signupToken,
            suggestedNickname: nickname,
            authRepository: repository,
            signupUseCase: SignupUseCaseImpl(authRepository: repository),
            userInfoStore: userInfoStore,
            selectableItemStore: selectableItemStore,
            appState: appState,
            context: context,
            analytics: analytics
        )
    }

    func signOut() async {
        await makeRepository().signOut()
    }
}
