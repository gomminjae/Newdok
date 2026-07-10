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

    public func makeMypageView(
        onEditProfile: @escaping () -> Void,
        onAccountManage: @escaping () -> Void,
        onEditAlert: @escaping () -> Void,
        onFAQ: @escaping () -> Void,
        onFeedback: @escaping () -> Void,
        onTermsMenu: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            MypageView(
                viewModel: container.sharedViewModel(),
                onEditProfile: onEditProfile,
                onAccountManage: onAccountManage,
                onEditAlert: onEditAlert,
                onFAQ: onFAQ,
                onFeedback: onFeedback,
                onTermsMenu: onTermsMenu
            )
        )
    }

    public func makeEditProfileView(
        onBack: @escaping () -> Void,
        onEditNickname: @escaping () -> Void,
        onEditIndustry: @escaping () -> Void,
        onEditInterest: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            EditProfileView(
                onBack: onBack,
                onEditNickname: onEditNickname,
                onEditIndustry: onEditIndustry,
                onEditInterest: onEditInterest
            )
            .environment(container.sharedViewModel())
        )
    }

    public func makeEditNicknameView(onBack: @escaping () -> Void) -> AnyView {
        let viewModel = container.sharedViewModel()
        let currentNickname = viewModel.user?.nickname
            ?? viewModel.loadUserInfo()?.nickname
            ?? ""
        return AnyView(
            EditNicknameView(initialNickname: currentNickname, onBack: onBack)
                .environment(viewModel)
        )
    }

    public func makeEditIndustryView(onBack: @escaping () -> Void) -> AnyView {
        AnyView(EditIndustryView(onBack: onBack).environment(container.sharedViewModel()))
    }

    public func makeEditInterestView(onBack: @escaping () -> Void) -> AnyView {
        AnyView(EditInterestView(onBack: onBack).environment(container.sharedViewModel()))
    }

    public func makeRecoveryView(
        onBack: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onServiceFeedback: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            RecoveryView(
                viewModel: container.makeRecoveryViewModel(),
                onBack: onBack,
                onSignup: onSignup,
                onLogin: onLogin,
                onServiceFeedback: onServiceFeedback
            )
        )
    }

    public func makeAccountManageView(
        onBack: @escaping () -> Void,
        onUpdatePhone: @escaping () -> Void,
        onUpdatePassword: @escaping () -> Void,
        onWithdraw: @escaping () -> Void,
        onLoggedOut: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            container.makeAccountManagementView(
                onLogoutCleanup: { [container] in container.clearCache() },
                onBack: onBack,
                onUpdatePhone: onUpdatePhone,
                onUpdatePassword: onUpdatePassword,
                onWithdraw: onWithdraw,
                onLoggedOut: onLoggedOut
            )
        )
    }

    public func makeChangePasswordView(onBack: @escaping () -> Void) -> AnyView {
        AnyView(PwdUpdateView(viewModel: container.makePasswordUpdateViewModel(), onBack: onBack))
    }

    public func makeChangePhoneNumberView(onBack: @escaping () -> Void) -> AnyView {
        AnyView(PhoneUpdateView(viewModel: container.makePhoneUpdateViewModel(), onBack: onBack))
    }

    public func makeWithdrawView(
        onBack: @escaping () -> Void,
        onWithdrawn: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            WithdrawView(
                viewModel: container.makeWithdrawViewModel(onCleanup: { [container] in
                    container.clearCache()
                }),
                onBack: onBack,
                onWithdrawn: onWithdrawn
            )
        )
    }

    public func makeFAQView(onBack: @escaping () -> Void) -> AnyView {
        AnyView(FAQView(onBack: onBack))
    }

    public func makeFeedbackView(onBack: @escaping () -> Void) -> AnyView {
        AnyView(FeedbackView(onBack: onBack))
    }

    public func makeTermsMenuView(onBack: @escaping () -> Void) -> AnyView {
        AnyView(TermsMenuView(onBack: onBack))
    }

    public func makeEditAlertView(onBack: @escaping () -> Void) -> AnyView {
        AnyView(EditAlertView(onBack: onBack))
    }

    public func makeVersionView(onBack: @escaping () -> Void) -> AnyView {
        AnyView(VersionView(onBack: onBack))
    }
}
