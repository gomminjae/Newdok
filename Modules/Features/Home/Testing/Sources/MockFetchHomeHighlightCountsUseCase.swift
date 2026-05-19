import Foundation
import HomeDomain

public final class MockFetchHomeHighlightCountsUseCase: FetchHomeHighlightCountsUseCase {
    public var result: [Int: Int] = [:]
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute(articleIds: [Int]) async -> [Int: Int] {
        executeCallCount += 1
        return result
    }
}
