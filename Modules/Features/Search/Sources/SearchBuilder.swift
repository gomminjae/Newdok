import SwiftUI
import Core
import SearchInterface
import SearchDomain
import SearchData

public struct SearchBuilder: SearchBuildable {
    private let network: any NetworkService<SearchAPI>

    public init(network: any NetworkService<SearchAPI>) {
        self.network = network
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
