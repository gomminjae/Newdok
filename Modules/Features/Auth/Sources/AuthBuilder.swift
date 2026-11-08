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
        onboardingStorage: OnboardingStorable,
        analytics: AnalyticsClient
    ) {
        self.container = AuthDIContainer(
            networkProvider: networkProvider,
            tokenStorage: tokenStorage,
            userInfoStore: userInfoStore,
            selectableItemStore: selectableItemStore,
            appState: appState,
            onboardingStorage: onboardingStorage,
            analytics: analytics
        )
    }

    public func makeOnboardingView(
        context: AuthAnalyticsContext = AuthAnalyticsContext(),
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            OnboardingView(
                context: context,
                onboardingStorage: container.onboardingStorage,
                onSignup: onSignup,
                onLogin: onLogin
            )
        )
    }

    public func makeLoginView(
        context: AuthAnalyticsContext = AuthAnalyticsContext(),
        canGoBack: Bool,
        onBack: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onNeedSignup: @escaping (String, String?) -> Void,
        onAuthenticated: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            LoginView(
                viewModel: container.makeLoginViewModel(context: context),
                canGoBack: canGoBack,
                onBack: onBack,
                onNeedSignup: onNeedSignup,
                onAuthenticated: onAuthenticated
            )
        )
    }

    public func makeSignupView(
        context: AuthAnalyticsContext = AuthAnalyticsContext(),
        signupToken: String,
        nickname: String?,
        onBack: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onAuthenticated: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            SignupView(
                viewModel: container.makeSignupViewModel(context: context, signupToken: signupToken, nickname: nickname),
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
