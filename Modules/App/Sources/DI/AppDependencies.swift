import Foundation
import NetworkKit
import DatabaseKit
import Shared

@MainActor
final class AppDependencies {
    let networkProvider: NetworkProviding
    let highlightDataSource: HighlightLocalDataSource
    let userInfoStore: UserInfoStoreProtocol
    let selectableItemStore: SelectableItemStoreProtocol
    let tokenStorage: TokenStorageProtocol
    let appState: AppState
    let subscribePopupPreference: SubscribePopupStorable
    let onboardingStorage: OnboardingStorable

    init(
        networkProvider: NetworkProviding = NetworkProvider(),
        highlightDataSource: HighlightLocalDataSource = DefaultHighlightLocalDataSource.shared,
        userInfoStore: UserInfoStoreProtocol = UserInfoStore.shared,
        selectableItemStore: SelectableItemStoreProtocol = SelectableItemStore.shared,
        tokenStorage: TokenStorageProtocol = TokenStore.shared,
        appState: AppState = .shared,
        subscribePopupPreference: SubscribePopupStorable = SubscribePopupPreference.shared,
        onboardingStorage: OnboardingStorable = OnboardingStorage.shared
    ) {
        self.networkProvider = networkProvider
        self.highlightDataSource = highlightDataSource
        self.userInfoStore = userInfoStore
        self.selectableItemStore = selectableItemStore
        self.tokenStorage = tokenStorage
        self.appState = appState
        self.subscribePopupPreference = subscribePopupPreference
        self.onboardingStorage = onboardingStorage
    }
}
