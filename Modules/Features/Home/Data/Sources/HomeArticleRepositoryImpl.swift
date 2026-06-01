import HomeDomain
import NetworkKit
import Shared

public final class HomeArticleRepositoryImpl: HomeArticleRepository {
    private let network: any NetworkService
    private let readArticleStore: ReadArticleStore

    public init(network: any NetworkService, readArticleStore: ReadArticleStore = ReadArticleStore()) {
        self.network = network
        self.readArticleStore = readArticleStore
    }

    public func fetchArticles(year: String, publicationMonth: String) async throws -> [HomeArticles] {
        logDebug("월별 아티클 조회 - \(year)년 \(publicationMonth)월", category: .repository)
        let response = try await network.request(FetchHomeArticles(year: year, publicationMonth: publicationMonth))
        logDebug("월별 아티클 조회 완료 - \(response.data.count)일", category: .repository)
        return response.data.map { $0.toDomain() }
    }

    public func fetchDayArticles(year: String, publicationMonth: String, publicationDate: String) async throws -> [HomeArticle] {
        logDebug("일별 아티클 조회 - \(year)-\(publicationMonth)-\(publicationDate)", category: .repository)
        let response = try await network.request(FetchHomeDayArticle(year: year, publicationMonth: publicationMonth, publicationDate: publicationDate))
        logDebug("일별 아티클 조회 완료 - \(response.count)개", category: .repository)
        return response.map { $0.toDomain }
    }

    public func fetchTodayArticles() async throws -> [HomeArticle] {
        logDebug("오늘 아티클 조회", category: .repository)
        let response = try await network.request(FetchHomeTodayArticle())
        logDebug("오늘 아티클 조회 완료 - \(response.count)개", category: .repository)
        return response.map { $0.toDomain }
    }

    public func refresh() async throws {
        try await network.requestVoid(RefreshHomeArticles())
    }

    public func loadReadArticleIds() -> Set<Int> {
        readArticleStore.load()
    }

    public func saveReadArticleIds(_ ids: Set<Int>) {
        readArticleStore.save(ids)
    }
}
