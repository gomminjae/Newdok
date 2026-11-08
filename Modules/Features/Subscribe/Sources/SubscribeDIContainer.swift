import Shared
import NetworkKit
import SubscribeDomain
import SubscribeData

struct SubscribeDIContainer {
    private let analytics: AnalyticsClient
    private let network: any NetworkService

    init(networkProvider: NetworkProviding, analytics: AnalyticsClient) {
        self.analytics = analytics
        self.network = networkProvider.makeService()
    }

    // MARK: - Repository

    private func makeRepository() -> SubscribeNewsletterRepository {
        SubscribeNewsletterRepositoryImpl(network: network)
    }

    // MARK: - UseCases

    private func makeFetchActiveUseCase() -> FetchActiveSubscriptionUseCase {
        FetchActiveSubscriptionUseCaseImpl(repository: makeRepository())
    }

    private func makeFetchPausedUseCase() -> FetchPausedSubscriptionUseCase {
        FetchPausedSubscriptionUseCaseImpl(repository: makeRepository())
    }

    private func makePauseUseCase() -> PauseSubscriptionUseCase {
        PauseSubscriptionUseCaseImpl(repository: makeRepository())
    }

    private func makeResumeUseCase() -> ResumeSubscriptionUseCase {
        ResumeSubscriptionUseCaseImpl(repository: makeRepository())
    }

    // MARK: - ViewModel

    @MainActor
    func makeViewModel() -> SubscribeViewModel {
        SubscribeViewModel(
            fetchActiveUseCase: makeFetchActiveUseCase(),
            fetchPausedUseCase: makeFetchPausedUseCase(),
            pauseUseCase: makePauseUseCase(),
            resumeUseCase: makeResumeUseCase(),
            analytics: analytics
        )
    }
}
