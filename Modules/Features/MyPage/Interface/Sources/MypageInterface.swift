import SwiftUI

@MainActor
public protocol MypageBuildable {
    func makeMypageView(
        onEditProfile: @escaping () -> Void,
        onAccountManage: @escaping () -> Void,
        onEditAlert: @escaping () -> Void,
        onFAQ: @escaping () -> Void,
        onFeedback: @escaping () -> Void,
        onTermsMenu: @escaping () -> Void
    ) -> AnyView

    func makeEditProfileView(
        onBack: @escaping () -> Void,
        onEditNickname: @escaping () -> Void,
        onEditIndustry: @escaping () -> Void,
        onEditInterest: @escaping () -> Void
    ) -> AnyView

    func makeEditNicknameView(onBack: @escaping () -> Void) -> AnyView
    func makeEditIndustryView(onBack: @escaping () -> Void) -> AnyView
    func makeEditInterestView(onBack: @escaping () -> Void) -> AnyView

    func makeAccountManageView(
        onBack: @escaping () -> Void,
        onWithdraw: @escaping () -> Void,
        onLoggedOut: @escaping () -> Void
    ) -> AnyView

    func makeWithdrawView(
        onBack: @escaping () -> Void,
        onWithdrawn: @escaping () -> Void
    ) -> AnyView

    func makeFAQView(onBack: @escaping () -> Void) -> AnyView
    func makeFeedbackView(onBack: @escaping () -> Void) -> AnyView
    func makeTermsMenuView(onBack: @escaping () -> Void) -> AnyView
    func makeEditAlertView(onBack: @escaping () -> Void) -> AnyView
    func makeVersionView(onBack: @escaping () -> Void) -> AnyView
}
