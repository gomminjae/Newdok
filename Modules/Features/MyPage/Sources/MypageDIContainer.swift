import NetworkKit
import Shared
import MypageDomain
import MypageData

@MainActor
final class MypageDIContainer {
    private let network: any NetworkService
    private let tokenStorage: TokenStorageProtocol
    private let userInfoStore: UserInfoStoreProtocol
    private let selectableItemStore: SelectableItemStoreProtocol
    private let appState: AppState

    private var cachedViewModel: MypageViewModel?

    init(
        networkProvider: NetworkProviding,
        tokenStorage: TokenStorageProtocol,
        userInfoStore: UserInfoStoreProtocol,
        selectableItemStore: SelectableItemStoreProtocol,
        appState: AppState
    ) {
        self.network = networkProvider.makeService()
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
        self.selectableItemStore = selectableItemStore
        self.appState = appState
    }

    // MARK: - Repositories

    func makeUserRepository() -> MypageUserRepository {
        MypageUserRepositoryImpl(network: network, userInfoStore: userInfoStore)
    }

    func makeStatsRepository() -> MypageStatsRepository {
        MypageStatsRepositoryImpl(network: network)
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
            updateIndustryUseCase: UpdateMypageIndustryUseCaseImpl(repository: repository),
            selectableItemStore: selectableItemStore,
            userInfoStore: userInfoStore
        )
        cachedViewModel = viewModel
        return viewModel
    }

    func clearCache() {
        cachedViewModel = nil
    }

    // MARK: - ViewModels

    func logout() {
        tokenStorage.clear()
        userInfoStore.clear()
        clearCache()
        appState.logout()
    }

    func makeWithdrawViewModel(onCleanup: @escaping () -> Void) -> WithdrawViewModel {
        let userRepository = makeUserRepository()
        let statsRepository = makeStatsRepository()
        return WithdrawViewModel(
            fetchProfileUseCase: FetchMypageProfileUseCaseImpl(repository: userRepository),
            fetchSubscriptionCountUseCase: FetchMypageSubscriptionCountUseCaseImpl(repository: statsRepository),
            fetchArticleCountUseCase: FetchReceivedArticleCountUseCaseImpl(repository: statsRepository),
            withdrawUseCase: MypageWithdrawUseCaseImpl(repository: userRepository),
            tokenStorage: tokenStorage,
            userInfoStore: userInfoStore,
            appState: appState,
            onCleanup: onCleanup
        )
    }
}
