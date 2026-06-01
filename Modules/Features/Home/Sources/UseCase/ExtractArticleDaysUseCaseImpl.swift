import HomeDomain

public final class ExtractArticleDaysUseCaseImpl: ExtractArticleDaysUseCase {
    public init() {}

    public func execute(from month: [HomeArticles]) -> Set<Int> {
        Set(month.filter { $0.hasArticles }.map { $0.publishDate })
    }
}
