import SwiftUI
import Core
import SubscribeInterface
import SubscribeDomain
import SubscribeData

public struct SubscribeBuilder: SubscribeBuildable {
    private let network: any NetworkService<SubscribeNewsletterAPI>

    public init(networkProvider: NetworkProviding) {
        self.network = SubscribeNetworkFactory.makeNewsletterNetwork(networkProvider)
    }

    public func makeSubscribeView() -> AnyView {
        let repository = SubscribeNewsletterRepositoryImpl(network: network)
        let viewModel = SubscribeViewModel(
            fetchActiveUseCase: FetchActiveSubscriptionUseCaseImpl(repository: repository),
            fetchPausedUseCase: FetchPausedSubscriptionUseCaseImpl(repository: repository),
            pauseUseCase: PauseSubscriptionUseCaseImpl(repository: repository),
            resumeUseCase: ResumeSubscriptionUseCaseImpl(repository: repository)
        )
        return AnyView(SubscribeView(viewModel: viewModel))
    }
}
