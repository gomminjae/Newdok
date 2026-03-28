import Foundation

public protocol FetchHomeDataUseCase: Sendable {
    func fetchTodayData() async throws -> HomeData
    func fetchMonthlyData(year: String, month: String) async throws -> [HomeArticles]
    func fetchDayArticles(year: String, month: String, day: String) async throws -> [HomeArticle]
    func decorateTodayArticles(_ articles: [HomeArticle], readArticleIds: Set<Int>) -> [HomeArticle]
    func unreadCount(in articles: [HomeArticle]) -> Int
    func refresh() async throws
}
