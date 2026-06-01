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

    public func makeOnboardingView() -> AnyView {
        AnyView(OnboardingView(onboardingStorage: container.onboardingStorage))
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
