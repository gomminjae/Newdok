import NetworkKit
import Shared
import ExploreDomain
import ExploreData

@MainActor
struct ExploreDIContainer {
    private let network: any NetworkService
    private let userInfoStore: UserInfoStoreProtocol
    private let selectableItemStore: SelectableItemStoreProtocol

    init(
        networkProvider: NetworkProviding,
        userInfoStore: UserInfoStoreProtocol = UserInfoStore.shared,
        selectableItemStore: SelectableItemStoreProtocol = SelectableItemStore.shared
    ) {
        self.network = networkProvider.makeService()
        self.userInfoStore = userInfoStore
        self.selectableItemStore = selectableItemStore
    }

    // MARK: - Repository

    private func makeRepository() -> ExploreNewsletterRepository {
        ExploreNewsletterRepositoryImpl(network: network)
    }

    // MARK: - UseCase

    private func makeFetchNewslettersUseCase() -> FetchExploreNewslettersUseCase {
        FetchExploreNewslettersUseCaseImpl(repository: makeRepository())
    }

    private func makeFetchBrandDetailUseCase() -> FetchExploreBrandDetailUseCase {
        FetchExploreBrandDetailUseCaseImpl(repository: makeRepository())
    }

    private func makeFetchGuestNewslettersUseCase() -> FetchGuestExploreNewslettersUseCase {
        FetchGuestExploreNewslettersUseCaseImpl(repository: makeRepository())
    }

    private func makeFetchRecommendationUseCase() -> FetchExploreRecommendationUseCase {
        FetchExploreRecommendationUseCaseImpl(repository: makeRepository())
    }

    private func makeLoadOptionsUseCase() -> LoadOptionsUseCase {
        LoadOptionsUseCaseImpl(
            repository: makeRepository(),
            selectableItemStore: selectableItemStore
        )
    }

    // MARK: - ViewModel

    @MainActor
    func makeViewModel() -> ExploreViewModel {
        ExploreViewModel(
            fetchNewslettersUseCase: makeFetchNewslettersUseCase(),
            fetchBrandDetailUseCase: makeFetchBrandDetailUseCase(),
            fetchGuestNewslettersUseCase: makeFetchGuestNewslettersUseCase(),
            fetchRecommendationUseCase: makeFetchRecommendationUseCase(),
            transformRecommendationUseCase: TransformExploreRecommendationUseCaseImpl(),
            prioritizeInterestsUseCase: PrioritizeInterestsUseCaseImpl(),
            userInfoStore: userInfoStore,
            selectableItemStore: selectableItemStore
        )
    }

    // MARK: - Side Effect

    func loadOptions() async throws {
        try await makeLoadOptionsUseCase().execute()
    }
}
