import HomeDomain
import Core
import Shared

public class HomeArticleRepositoryImpl: HomeArticleRepository {
    private let network: any NetworkService<ArticleAPI>

    public init(network: any NetworkService<ArticleAPI>) {
        self.network = network
    }

    public func fetchArticles(year: String, publicationMonth: String) async throws -> [HomeArticles] {
        logDebug("월별 아티클 조회 - \(year)년 \(publicationMonth)월", category: .repository)
        let response: HomeArticlesResponseDTO = try await network.request(.fetchArticles(year: year, publicationMonth: publicationMonth))
        logDebug("월별 아티클 조회 완료 - \(response.data.count)일", category: .repository)
        return response.data.map { $0.toDomain() }
    }

    public func fetchDayArticles(year: String, publicationMonth: String, publicationDate: String) async throws -> [HomeArticle] {
        logDebug("일별 아티클 조회 - \(year)-\(publicationMonth)-\(publicationDate)", category: .repository)
        let response: [HomeArticleDTO] = try await network.request(.fetchDayArticle(year: year, publicationMonth: publicationMonth, publicationDate: publicationDate))
        logDebug("일별 아티클 조회 완료 - \(response.count)개", category: .repository)
        return response.map { $0.toDomain }
    }

    public func fetchTodayArticles() async throws -> [HomeArticle] {
        logDebug("오늘 아티클 조회", category: .repository)
        let response: [HomeArticleDTO] = try await network.request(.fetchTodayArticle)
        logDebug("오늘 아티클 조회 완료 - \(response.count)개", category: .repository)
        return response.map { $0.toDomain }
    }

    public func refresh() async throws {
        try await network.requestVoid(.refresh)
    }
}
