public protocol MergeDayArticleSummaryUseCase: Sendable {
    func execute(day: Int, dayArticles: [HomeArticle], into month: [HomeArticles]) -> [HomeArticles]
}
