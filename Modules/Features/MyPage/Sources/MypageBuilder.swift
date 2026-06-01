import SwiftUI
import NetworkKit
import Shared
import MypageInterface

public struct MypageBuilder: MypageBuildable {
    private let container: MypageDIContainer

    public init(
        networkProvider: NetworkProviding,
        tokenStorage: TokenStorageProtocol,
        userInfoStore: UserInfoStoreProtocol,
        selectableItemStore: SelectableItemStoreProtocol,
        appState: AppState
    ) {
        self.container = MypageDIContainer(
            networkProvider: networkProvider,
            tokenStorage: tokenStorage,
            userInfoStore: userInfoStore,
            selectableItemStore: selectableItemStore,
            appState: appState
        )
    }

    public func makeMypageView() -> AnyView {
        AnyView(MypageView(viewModel: container.sharedViewModel()))
    }

    public func makeEditProfileView() -> AnyView {
        AnyView(EditProfileView().environment(container.sharedViewModel()))
    }

    public func makeEditNicknameView() -> AnyView {
        let viewModel = container.sharedViewModel()
        let currentNickname = viewModel.user?.nickname
            ?? viewModel.loadUserInfo()?.nickname
            ?? ""
        return AnyView(EditNicknameView(initialNickname: currentNickname).environment(viewModel))
    }

    public func makeEditIndustryView() -> AnyView {
        AnyView(EditIndustryView().environment(container.sharedViewModel()))
    }

    public func makeEditInterestView() -> AnyView {
        AnyView(EditInterestView().environment(container.sharedViewModel()))
    }

    public func makeRecoveryView() -> AnyView {
        AnyView(RecoveryView(viewModel: container.makeRecoveryViewModel()))
    }

    public func makeAccountManageView() -> AnyView {
        AnyView(container.makeAccountManagementView(onLogoutCleanup: { [container] in
            container.clearCache()
        }))
    }

    public func makeChangePasswordView() -> AnyView {
        AnyView(PwdUpdateView(viewModel: container.makePasswordUpdateViewModel()))
    }

    public func makeChangePhoneNumberView() -> AnyView {
        AnyView(PhoneUpdateView(viewModel: container.makePhoneUpdateViewModel()))
    }

    public func makeWithdrawView() -> AnyView {
        AnyView(WithdrawView(viewModel: container.makeWithdrawViewModel(onCleanup: { [container] in
            container.clearCache()
        })))
    }

    public func makeFAQView() -> AnyView {
        AnyView(FAQView())
    }

    public func makeFeedbackView() -> AnyView {
        AnyView(FeedbackView())
    }

    public func makeTermsMenuView() -> AnyView {
        AnyView(TermsMenuView())
    }

    public func makeEditAlertView() -> AnyView {
        AnyView(EditAlertView())
    }
}
