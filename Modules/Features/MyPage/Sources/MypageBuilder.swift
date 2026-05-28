import SwiftUI
import Core
import MypageInterface
import MypageDomain
import MypageData

@MainActor
public final class MypageBuilder: MypageBuildable {
    private let userNetwork: any NetworkService<MypageUserAPI>
    private let articleNetwork: any NetworkService<MypageArticleAPI>
    private let newsletterNetwork: any NetworkService<MypageNewsletterAPI>

    private var cachedViewModel: MypageViewModel?

    public init(networkProvider: NetworkProviding) {
        self.userNetwork = MypageNetworkFactory.makeUserNetwork(networkProvider)
        self.articleNetwork = MypageNetworkFactory.makeArticleNetwork(networkProvider)
        self.newsletterNetwork = MypageNetworkFactory.makeNewsletterNetwork(networkProvider)
    }

    private func makeUserRepository() -> MypageUserRepository {
        MypageUserRepositoryImpl(network: userNetwork)
    }

    private func makeStatsRepository() -> MypageStatsRepository {
        MypageStatsRepositoryImpl(articleNetwork: articleNetwork, newsletterNetwork: newsletterNetwork)
    }

    private func sharedViewModel() -> MypageViewModel {
        if let cached = cachedViewModel {
            return cached
        }
        let repository = makeUserRepository()
        let viewModel = MypageViewModel(
            fetchProfileUseCase: FetchMypageProfileUseCaseImpl(repository: repository),
            updateNicknameUseCase: UpdateMypageNicknameUseCaseImpl(repository: repository),
            updateInterestsUseCase: UpdateMypageInterestsUseCaseImpl(repository: repository),
            updateIndustryUseCase: UpdateMypageIndustryUseCaseImpl(repository: repository)
        )
        cachedViewModel = viewModel
        return viewModel
    }

    private func clearCache() {
        cachedViewModel = nil
    }

    public func makeMypageView() -> AnyView {
        AnyView(MypageView(viewModel: sharedViewModel()))
    }

    public func makeEditProfileView() -> AnyView {
        AnyView(EditProfileView().environment(sharedViewModel()))
    }

    public func makeEditNicknameView() -> AnyView {
        let viewModel = sharedViewModel()
        let currentNickname = viewModel.user?.nickname
            ?? viewModel.loadUserInfo()?.nickname
            ?? ""
        return AnyView(EditNicknameView(initialNickname: currentNickname).environment(viewModel))
    }

    public func makeEditIndustryView() -> AnyView {
        AnyView(EditIndustryView().environment(sharedViewModel()))
    }

    public func makeEditInterestView() -> AnyView {
        AnyView(EditInterestView().environment(sharedViewModel()))
    }

    public func makeRecoveryView() -> AnyView {
        let repository = makeUserRepository()
        let viewModel = RecoveryViewModel(
            checkPhoneNumberUseCase: CheckMypagePhoneNumberUseCaseImpl(repository: repository),
            checkIDDupUseCase: CheckMypageIDDupUseCaseImpl(repository: repository),
            authSMSUseCase: MypageAuthSMSUseCaseImpl(repository: repository),
            resetPasswordUseCase: ResetMypagePasswordUseCaseImpl(repository: repository)
        )
        return AnyView(RecoveryView(viewModel: viewModel))
    }

    public func makeAccountManageView() -> AnyView {
        AnyView(AccountManagementView(onLogoutCleanup: { [weak self] in
            self?.clearCache()
        }))
    }

    public func makeChangePasswordView() -> AnyView {
        let repository = makeUserRepository()
        let viewModel = PasswordUpdateViewModel(
            updatePasswordUseCase: UpdateMypagePasswordUseCaseImpl(repository: repository)
        )
        return AnyView(PwdUpdateView(viewModel: viewModel))
    }

    public func makeChangePhoneNumberView() -> AnyView {
        let repository = makeUserRepository()
        let viewModel = PhoneUpdateViewModel(
            authSMSUseCase: MypageAuthSMSUseCaseImpl(repository: repository),
            updatePhoneNumberUseCase: UpdateMypagePhoneNumberUseCaseImpl(repository: repository)
        )
        return AnyView(PhoneUpdateView(viewModel: viewModel))
    }

    public func makeWithdrawView() -> AnyView {
        let userRepository = makeUserRepository()
        let statsRepository = makeStatsRepository()
        let viewModel = WithdrawViewModel(
            fetchProfileUseCase: FetchMypageProfileUseCaseImpl(repository: userRepository),
            fetchSubscriptionCountUseCase: FetchMypageSubscriptionCountUseCaseImpl(repository: statsRepository),
            fetchArticleCountUseCase: FetchReceivedArticleCountUseCaseImpl(repository: statsRepository),
            withdrawUseCase: MypageWithdrawUseCaseImpl(repository: userRepository),
            onCleanup: { [weak self] in
                self?.clearCache()
            }
        )
        return AnyView(WithdrawView(viewModel: viewModel))
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
