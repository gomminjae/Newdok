import SwiftUI
import Core
import SearchInterface
import SearchDomain
import SearchData

public struct SearchBuilder: SearchBuildable {
    private let network: any NetworkService<SearchAPI>

    public init(networkProvider: NetworkProviding) {
        self.network = SearchNetworkFactory.makeSearchNetwork(networkProvider)
    }

    public func makeSearchView() -> AnyView {
        let repository = SearchRepositoryImpl(network: network)
        let viewModel = SearchViewModel(
            searchNewslettersUseCase: SearchNewslettersUseCaseImpl(repository: repository),
            fetchPopularKeywordsUseCase: FetchPopularKeywordsUseCaseImpl(repository: repository)
        )
        return AnyView(SearchView(viewModel: viewModel))
    }
}
