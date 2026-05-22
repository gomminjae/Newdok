import SwiftUI

@MainActor
public protocol MypageBuildable {
    func makeMypageView() -> AnyView
    func makeEditProfileView() -> AnyView
    func makeEditNicknameView() -> AnyView
    func makeEditIndustryView() -> AnyView
    func makeEditInterestView() -> AnyView
    func makeRecoveryView() -> AnyView
    func makeAccountManageView() -> AnyView
    func makeChangePasswordView() -> AnyView
    func makeChangePhoneNumberView() -> AnyView
    func makeWithdrawView() -> AnyView
    func makeFAQView() -> AnyView
    func makeFeedbackView() -> AnyView
    func makeTermsMenuView() -> AnyView
    func makeEditAlertView() -> AnyView
}
