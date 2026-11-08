import Shared
import NetworkKit
import SearchDomain
import SearchData

@MainActor
final class SearchDIContainer {
    private let analytics: AnalyticsClient
    private let network: any NetworkService

    init(networkProvider: NetworkProviding, analytics: AnalyticsClient) {
        self.analytics = analytics
        self.network = networkProvider.makeService()
    }

    func makeRepository() -> SearchRepository {
        SearchRepositoryImpl(network: network)
    }

    func makeSearchViewModel() -> SearchViewModel {
        let repository = makeRepository()
        return SearchViewModel(
            searchNewslettersUseCase: SearchNewslettersUseCaseImpl(repository: repository),
            fetchPopularKeywordsUseCase: FetchPopularKeywordsUseCaseImpl(repository: repository),
            analytics: analytics
        )
    }
}
