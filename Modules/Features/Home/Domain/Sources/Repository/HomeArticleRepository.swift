import Foundation

public protocol HomeArticleRepository: Sendable {
    func fetchArticles(year: String, publicationMonth: String) async throws -> [HomeArticles]
    func fetchDayArticles(year: String, publicationMonth: String, publicationDate: String) async throws -> [HomeArticle]
    func fetchTodayArticles() async throws -> [HomeArticle]
    func refresh() async throws

    func loadReadArticleIds() -> Set<Int>
    func saveReadArticleIds(_ ids: Set<Int>)
}
