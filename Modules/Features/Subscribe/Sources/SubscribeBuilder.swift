import SwiftUI
import Core
import SubscribeInterface
import SubscribeDomain
import SubscribeData

public struct SubscribeBuilder: SubscribeBuildable {
    private let network: any NetworkService<NewsletterAPI>

    public init(network: any NetworkService<NewsletterAPI>) {
        self.network = network
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
