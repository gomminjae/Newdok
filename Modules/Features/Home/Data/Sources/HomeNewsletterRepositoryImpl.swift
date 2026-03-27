import HomeDomain
import Core
import Shared
import Moya

public class HomeNewsletterRepositoryImpl: HomeNewsletterRepository {
    private let provider: MoyaProvider<NewsletterAPI>

    public init(provider: MoyaProvider<NewsletterAPI>) {
        self.provider = provider
    }

    public func fetchActiveSubscription() async throws -> [HomeNewsletter] {
        let response: [HomeNewsletterDTO] = try await provider.asyncRequest(.fetchActiveNewletters)
        return response.map { $0.toDomain() }
    }
}
