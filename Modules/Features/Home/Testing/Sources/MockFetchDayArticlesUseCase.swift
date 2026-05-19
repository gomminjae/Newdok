import Foundation
import HomeDomain

public final class MockFetchDayArticlesUseCase: FetchDayArticlesUseCase {
    public var result: Result<[HomeArticle], Error> = .success([])
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute(year: String, publicationMonth: String, publicationDate: String) async throws -> [HomeArticle] {
        executeCallCount += 1
        return try result.get()
    }
}
