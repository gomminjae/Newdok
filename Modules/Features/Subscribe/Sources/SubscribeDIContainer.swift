import Core
import SubscribeDomain
import SubscribeData

struct SubscribeDIContainer {
    private let network: any NetworkService<SubscribeNewsletterAPI>

    init(networkProvider: NetworkProviding) {
        self.network = networkProvider.makeService(for: SubscribeNewsletterAPI.self)
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
            resumeUseCase: makeResumeUseCase()
        )
    }
}
