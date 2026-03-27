import SwiftUI
import MypageInterface
import Domain
import DesignSystem
import Shared

public struct MypageViewFactoryImpl: MypageViewFactory {
    private let mypageViewModelProvider: @MainActor () -> MypageViewModel
    private let recoveryViewModelProvider: @MainActor () -> RecoveryViewModel
    private let withdrawViewModelProvider: @MainActor () -> WithdrawViewModel

    public init(
        mypageViewModelProvider: @MainActor @escaping () -> MypageViewModel,
        recoveryViewModelProvider: @MainActor @escaping () -> RecoveryViewModel,
        withdrawViewModelProvider: @MainActor @escaping () -> WithdrawViewModel
    ) {
        self.mypageViewModelProvider = mypageViewModelProvider
        self.recoveryViewModelProvider = recoveryViewModelProvider
        self.withdrawViewModelProvider = withdrawViewModelProvider
    }

    @MainActor public func makeMypageView() -> AnyView {
        let vm = mypageViewModelProvider()
        return AnyView(MypageView(viewModel: vm))
    }

    @MainActor public func makeEditProfileView() -> AnyView {
        let vm = mypageViewModelProvider()
        return AnyView(EditProfileView().environmentObject(vm))
    }

    @MainActor public func makeEditNicknameView() -> AnyView {
        let vm = mypageViewModelProvider()
        return AnyView(EditNicknameView(nickname: .constant("")).environmentObject(vm))
    }

    @MainActor public func makeEditIndustryView() -> AnyView {
        let vm = mypageViewModelProvider()
        return AnyView(EditIndustryView().environmentObject(vm))
    }

    @MainActor public func makeEditInterestView() -> AnyView {
        let vm = mypageViewModelProvider()
        return AnyView(EditInterestView().environmentObject(vm))
    }

    @MainActor public func makeRecoveryView() -> AnyView {
        let vm = recoveryViewModelProvider()
        return AnyView(RecoveryView(viewModel: vm))
    }

    @MainActor public func makeAccountManageView() -> AnyView {
        return AnyView(AccountManagementView())
    }

    @MainActor public func makeChangePasswordView() -> AnyView {
        let vm = mypageViewModelProvider()
        return AnyView(PwdUpdateView(viewModel: vm))
    }

    @MainActor public func makeChangePhoneNumberView() -> AnyView {
        let vm = mypageViewModelProvider()
        return AnyView(PhoneUpdateView(viewModel: vm))
    }

    @MainActor public func makeWithdrawView() -> AnyView {
        let vm = withdrawViewModelProvider()
        return AnyView(WithdrawView(viewModel: vm))
    }

    @MainActor public func makeFAQView() -> AnyView {
        return AnyView(FAQView())
    }

    @MainActor public func makeFeedbackView() -> AnyView {
        return AnyView(FeedbackView())
    }

    @MainActor public func makeTermsMenuView() -> AnyView {
        return AnyView(TermsMenuView())
    }

    @MainActor public func makeEditAlertView() -> AnyView {
        return AnyView(EditAlertView())
    }
}
