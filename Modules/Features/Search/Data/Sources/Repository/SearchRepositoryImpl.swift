import Foundation
import SearchDomain
import Core
import Shared

public final class SearchRepositoryImpl: SearchRepository {
    private let network: any NetworkService<SearchAPI>

    public init(network: any NetworkService<SearchAPI>) {
        self.network = network
    }

    public func searchNewsletters(brandName: String) async throws -> [SearchedNewsletter] {
        logDebug("뉴스레터 검색 - 브랜드명: \(brandName)", category: .repository)
        let response: [SearchedNewsletterDTO] = try await network.request(.searchNewsletters(brandName: brandName))
        logDebug("뉴스레터 검색 완료 - \(response.count)개", category: .repository)
        return response.map { $0.toDomain() }
    }

    public func fetchPopularKeywords() async throws -> PopularKeywordList {
        logDebug("인기 검색어 조회", category: .repository)
        let response: PopularKeywordResponseDTO = try await network.request(.popularKeywords)
        return response.toDomain()
    }
}
