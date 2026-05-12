import SwiftUI
import MypageInterface
import MypageDomain
import DesignSystem
import Shared

public final class MypageViewFactoryImpl: MypageViewFactory {
    private let mypageViewModelProvider: @MainActor () -> MypageViewModel
    private let recoveryViewModelProvider: @MainActor () -> RecoveryViewModel
    private let withdrawViewModelProvider: @MainActor () -> WithdrawViewModel

    @MainActor private var cachedMypageViewModel: MypageViewModel?

    public init(
        mypageViewModelProvider: @MainActor @escaping () -> MypageViewModel,
        recoveryViewModelProvider: @MainActor @escaping () -> RecoveryViewModel,
        withdrawViewModelProvider: @MainActor @escaping () -> WithdrawViewModel
    ) {
        self.mypageViewModelProvider = mypageViewModelProvider
        self.recoveryViewModelProvider = recoveryViewModelProvider
        self.withdrawViewModelProvider = withdrawViewModelProvider

        NotificationCenter.default.addObserver(
            forName: .init("ResetMypageCache"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.resetCache()
            }
        }
    }

    @MainActor public func resetCache() {
        cachedMypageViewModel = nil
    }

    @MainActor private func sharedMypageViewModel() -> MypageViewModel {
        if let cached = cachedMypageViewModel {
            return cached
        }
        let vm = mypageViewModelProvider()
        cachedMypageViewModel = vm
        return vm
    }

    @MainActor public func makeMypageView() -> AnyView {
        let vm = sharedMypageViewModel()
        return AnyView(MypageView(viewModel: vm))
    }

    @MainActor public func makeEditProfileView() -> AnyView {
        let vm = sharedMypageViewModel()
        return AnyView(EditProfileView().environment(vm))
    }

    @MainActor public func makeEditNicknameView() -> AnyView {
        let vm = sharedMypageViewModel()
        let currentNickname = vm.user?.nickname
            ?? vm.loadUserInfo()?.nickname
            ?? ""
        return AnyView(
            EditNicknameView(initialNickname: currentNickname)
                .environment(vm)
        )
    }

    @MainActor public func makeEditIndustryView() -> AnyView {
        let vm = sharedMypageViewModel()
        return AnyView(EditIndustryView().environment(vm))
    }

    @MainActor public func makeEditInterestView() -> AnyView {
        let vm = sharedMypageViewModel()
        return AnyView(EditInterestView().environment(vm))
    }

    @MainActor public func makeRecoveryView() -> AnyView {
        let vm = recoveryViewModelProvider()
        return AnyView(RecoveryView(viewModel: vm))
    }

    @MainActor public func makeAccountManageView() -> AnyView {
        return AnyView(AccountManagementView())
    }

    @MainActor public func makeChangePasswordView() -> AnyView {
        let vm = sharedMypageViewModel()
        return AnyView(PwdUpdateView(viewModel: vm))
    }

    @MainActor public func makeChangePhoneNumberView() -> AnyView {
        let vm = sharedMypageViewModel()
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
