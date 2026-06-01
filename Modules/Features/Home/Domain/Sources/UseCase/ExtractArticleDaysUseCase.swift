public protocol ExtractArticleDaysUseCase: Sendable {
    func execute(from month: [HomeArticles]) -> Set<Int>
}
