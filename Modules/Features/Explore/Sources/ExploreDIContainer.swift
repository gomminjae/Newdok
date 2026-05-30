import Core
import Shared
import ExploreDomain
import ExploreData

struct ExploreDIContainer {
    private let network: any NetworkService<ExploreNewsletterAPI>

    init(networkProvider: NetworkProviding) {
        self.network = networkProvider.makeService(for: ExploreNewsletterAPI.self)
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
            selectableItemStore: SelectableItemStore.shared
        )
    }

    // MARK: - ViewModel

    @MainActor
    func makeViewModel() -> ExploreViewModel {
        ExploreViewModel(
            fetchNewslettersUseCase: makeFetchNewslettersUseCase(),
            fetchBrandDetailUseCase: makeFetchBrandDetailUseCase(),
            fetchGuestNewslettersUseCase: makeFetchGuestNewslettersUseCase(),
            fetchRecommendationUseCase: makeFetchRecommendationUseCase()
        )
    }

    // MARK: - Side Effect

    func loadOptions() async throws {
        try await makeLoadOptionsUseCase().execute()
    }
}
