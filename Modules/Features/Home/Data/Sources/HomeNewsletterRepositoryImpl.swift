import HomeDomain
import Core
import Shared

public final class HomeNewsletterRepositoryImpl: HomeNewsletterRepository {
    private let network: any NetworkService<HomeNewsletterAPI>

    public init(network: any NetworkService<HomeNewsletterAPI>) {
        self.network = network
    }

    public func fetchActiveSubscription() async throws -> [HomeNewsletter] {
        let response: [HomeNewsletterDTO] = try await network.request(.fetchActiveNewletters)
        return response.map { $0.toDomain() }
    }
}
