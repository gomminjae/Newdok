import SwiftUI
import NetworkKit
import Shared
import AuthInterface

public struct AuthBuilder: AuthBuildable {
    private let container: AuthDIContainer

    public init(
        networkProvider: NetworkProviding,
        tokenStorage: TokenStorageProtocol,
        userInfoStore: UserInfoStoreProtocol,
        selectableItemStore: SelectableItemStoreProtocol,
        appState: AppState,
        onboardingStorage: OnboardingStorable
    ) {
        self.container = AuthDIContainer(
            networkProvider: networkProvider,
            tokenStorage: tokenStorage,
            userInfoStore: userInfoStore,
            selectableItemStore: selectableItemStore,
            appState: appState,
            onboardingStorage: onboardingStorage
        )
    }

    public func makeOnboardingView(
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            OnboardingView(
                onboardingStorage: container.onboardingStorage,
                onSignup: onSignup,
                onLogin: onLogin
            )
        )
    }

    public func makeLoginView(
        canGoBack: Bool,
        onBack: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onNeedSignup: @escaping (String, String?) -> Void,
        onAuthenticated: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            LoginView(
                viewModel: container.makeLoginViewModel(),
                canGoBack: canGoBack,
                onBack: onBack,
                onNeedSignup: onNeedSignup,
                onAuthenticated: onAuthenticated
            )
        )
    }

    public func makeSignupView(
        signupToken: String,
        nickname: String?,
        onBack: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onAuthenticated: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            SignupView(
                viewModel: container.makeSignupViewModel(signupToken: signupToken, nickname: nickname),
                onBack: onBack,
                onLogin: onLogin,
                onAuthenticated: onAuthenticated
            )
        )
    }

    public func signOut() async {
        await container.signOut()
    }
}
