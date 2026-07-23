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
        onEditAlert: @escaping () -> Void,
        onFAQ: @escaping () -> Void,
        onFeedback: @escaping () -> Void,
        onTermsMenu: @escaping () -> Void,
        onLoggedOut: @escaping () -> Void,
        onWithdraw: @escaping () -> Void
    ) -> AnyView {
        AnyView(
            MypageView(
                viewModel: container.sharedViewModel(),
                onEditProfile: onEditProfile,
                onEditAlert: onEditAlert,
                onFAQ: onFAQ,
                onFeedback: onFeedback,
                onTermsMenu: onTermsMenu,
                onLogout: { [container] in
                    container.logout()
                    onLoggedOut()
                },
                onWithdraw: onWithdraw
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
