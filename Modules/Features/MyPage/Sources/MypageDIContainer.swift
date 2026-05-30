import Core
import MypageDomain
import MypageData

@MainActor
final class MypageDIContainer {
    private let userNetwork: any NetworkService<MypageUserAPI>
    private let articleNetwork: any NetworkService<MypageArticleAPI>
    private let newsletterNetwork: any NetworkService<MypageNewsletterAPI>

    private var cachedViewModel: MypageViewModel?

    init(networkProvider: NetworkProviding) {
        self.userNetwork = networkProvider.makeService(for: MypageUserAPI.self)
        self.articleNetwork = networkProvider.makeService(for: MypageArticleAPI.self)
        self.newsletterNetwork = networkProvider.makeService(for: MypageNewsletterAPI.self)
    }

    // MARK: - Repositories

    func makeUserRepository() -> MypageUserRepository {
        MypageUserRepositoryImpl(network: userNetwork)
    }

    func makeStatsRepository() -> MypageStatsRepository {
        MypageStatsRepositoryImpl(articleNetwork: articleNetwork, newsletterNetwork: newsletterNetwork)
    }

    // MARK: - Shared ViewModel (cached)

    func sharedViewModel() -> MypageViewModel {
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

    func clearCache() {
        cachedViewModel = nil
    }

    // MARK: - ViewModels

    func makeRecoveryViewModel() -> RecoveryViewModel {
        let repository = makeUserRepository()
        return RecoveryViewModel(
            checkPhoneNumberUseCase: CheckMypagePhoneNumberUseCaseImpl(repository: repository),
            checkIDDupUseCase: CheckMypageIDDupUseCaseImpl(repository: repository),
            authSMSUseCase: MypageAuthSMSUseCaseImpl(repository: repository),
            resetPasswordUseCase: ResetMypagePasswordUseCaseImpl(repository: repository)
        )
    }

    func makePasswordUpdateViewModel() -> PasswordUpdateViewModel {
        let repository = makeUserRepository()
        return PasswordUpdateViewModel(
            updatePasswordUseCase: UpdateMypagePasswordUseCaseImpl(repository: repository)
        )
    }

    func makePhoneUpdateViewModel() -> PhoneUpdateViewModel {
        let repository = makeUserRepository()
        return PhoneUpdateViewModel(
            authSMSUseCase: MypageAuthSMSUseCaseImpl(repository: repository),
            updatePhoneNumberUseCase: UpdateMypagePhoneNumberUseCaseImpl(repository: repository)
        )
    }

    func makeWithdrawViewModel(onCleanup: @escaping () -> Void) -> WithdrawViewModel {
        let userRepository = makeUserRepository()
        let statsRepository = makeStatsRepository()
        return WithdrawViewModel(
            fetchProfileUseCase: FetchMypageProfileUseCaseImpl(repository: userRepository),
            fetchSubscriptionCountUseCase: FetchMypageSubscriptionCountUseCaseImpl(repository: statsRepository),
            fetchArticleCountUseCase: FetchReceivedArticleCountUseCaseImpl(repository: statsRepository),
            withdrawUseCase: MypageWithdrawUseCaseImpl(repository: userRepository),
            onCleanup: onCleanup
        )
    }
}
