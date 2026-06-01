import Foundation
import MypageDomain
import NetworkKit

public final class MypageStatsRepositoryImpl: MypageStatsRepository {
    private let network: any NetworkService

    public init(network: any NetworkService) {
        self.network = network
    }

    public func fetchReceivedArticleCount() async throws -> Int {
        let response = try await network.request(FetchReceivedArticleCount())
        return response.count
    }

    public func fetchSubscriptionCount() async throws -> Int {
        let response = try await network.request(FetchMypageSubscriptionCount())
        return response.count
    }
}
