import Foundation
import SearchDomain
import NetworkKit
import Shared

public final class SearchRepositoryImpl: SearchRepository {
    private let network: any NetworkService

    public init(network: any NetworkService) {
        self.network = network
    }

    public func searchNewsletters(brandName: String) async throws -> [SearchedNewsletter] {
        logDebug("뉴스레터 검색 - 브랜드명: \(brandName)", category: .repository)
        let response = try await network.request(SearchNewslettersRequest(brandName: brandName))
        logDebug("뉴스레터 검색 완료 - \(response.count)개", category: .repository)
        return response.map { $0.toDomain() }
    }

    public func fetchPopularKeywords() async throws -> PopularKeywordList {
        logDebug("인기 검색어 조회", category: .repository)
        let response = try await network.request(PopularKeywordsRequest())
        return response.toDomain()
    }
}
