import SwiftUI

public protocol MypageViewFactory {
    @MainActor func makeMypageView() -> AnyView
    @MainActor func makeEditProfileView() -> AnyView
    @MainActor func makeEditNicknameView() -> AnyView
    @MainActor func makeEditIndustryView() -> AnyView
    @MainActor func makeEditInterestView() -> AnyView
    @MainActor func makeRecoveryView() -> AnyView
    @MainActor func makeAccountManageView() -> AnyView
    @MainActor func makeChangePasswordView() -> AnyView
    @MainActor func makeChangePhoneNumberView() -> AnyView
    @MainActor func makeWithdrawView() -> AnyView
    @MainActor func makeFAQView() -> AnyView
    @MainActor func makeFeedbackView() -> AnyView
    @MainActor func makeTermsMenuView() -> AnyView
    @MainActor func makeEditAlertView() -> AnyView
}
