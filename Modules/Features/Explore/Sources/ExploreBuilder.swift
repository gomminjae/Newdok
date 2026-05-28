import SwiftUI
import Core
import Shared
import ExploreInterface
import ExploreDomain
import ExploreData

public struct ExploreBuilder: ExploreBuildable {
    private let network: any NetworkService<ExploreNewsletterAPI>

    public init(networkProvider: NetworkProviding) {
        self.network = ExploreNetworkFactory.makeNewsletterNetwork(networkProvider)
    }

    public func makeExploreView() -> AnyView {
        let repository = ExploreNewsletterRepositoryImpl(network: network)
        let viewModel = ExploreViewModel(
            fetchNewslettersUseCase: FetchExploreNewslettersUseCaseImpl(repository: repository),
            fetchBrandDetailUseCase: FetchExploreBrandDetailUseCaseImpl(repository: repository),
            fetchGuestNewslettersUseCase: FetchGuestExploreNewslettersUseCaseImpl(repository: repository),
            fetchRecommendationUseCase: FetchExploreRecommendationUseCaseImpl(repository: repository)
        )
        return AnyView(ExploreView(viewModel: viewModel))
    }

    public func loadOptions() async throws {
        let repository = ExploreNewsletterRepositoryImpl(network: network)
        try await LoadOptionsUseCaseImpl(
            repository: repository,
            selectableItemStore: SelectableItemStore.shared
        ).execute()
    }
}
