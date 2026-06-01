import HomeDomain
import NetworkKit
import Shared

public final class HomeNewsletterRepositoryImpl: HomeNewsletterRepository {
    private let network: any NetworkService

    public init(network: any NetworkService) {
        self.network = network
    }

    public func fetchActiveSubscription() async throws -> [HomeNewsletter] {
        let response = try await network.request(FetchHomeActiveNewsletters())
        return response.map { $0.toDomain() }
    }
}
