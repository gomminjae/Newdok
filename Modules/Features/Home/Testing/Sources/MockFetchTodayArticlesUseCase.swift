import Foundation
import HomeDomain

public final class MockFetchTodayArticlesUseCase: FetchTodayArticlesUseCase {
    public var result: Result<[HomeArticle], Error> = .success([])
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws -> [HomeArticle] {
        executeCallCount += 1
        return try result.get()
    }
}
