import Foundation
import HomeDomain

public final class MockFetchMonthArticlesUseCase: FetchMonthArticlesUseCase {
    public var result: Result<[HomeArticles], Error> = .success([])
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute(year: String, publicationMonth: String) async throws -> [HomeArticles] {
        executeCallCount += 1
        return try result.get()
    }
}
