import HomeDomain
import DatabaseKit

public final class HighlightCountRepositoryImpl: HighlightCountRepository {
    private let dataSource: HighlightLocalDataSource

    public init(dataSource: HighlightLocalDataSource) {
        self.dataSource = dataSource
    }

    public func highlightCounts(forArticleIds ids: [Int]) async -> [Int: Int] {
        await dataSource.counts(forArticleIds: ids)
    }
}
