import Foundation
import HomeDomain

public final class MockSaveReadArticleIdsUseCase: SaveReadArticleIdsUseCase {
    public private(set) var savedIds: Set<Int>?
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute(_ ids: Set<Int>) {
        executeCallCount += 1
        savedIds = ids
    }
}
