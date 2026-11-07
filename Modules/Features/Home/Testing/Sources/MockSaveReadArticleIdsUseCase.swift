import Foundation
import HomeDomain
import Synchronization

public final class MockSaveReadArticleIdsUseCase: SaveReadArticleIdsUseCase {
    private struct State {
        var savedIds: Set<Int>?
        var executeCallCount = 0
    }

    private let state = Mutex(State())

    public var savedIds: Set<Int>? { state.withLock { $0.savedIds } }
    public var executeCallCount: Int { state.withLock { $0.executeCallCount } }

    public init() {}

    public func execute(_ ids: Set<Int>) {
        state.withLock {
            $0.executeCallCount += 1
            $0.savedIds = ids
        }
    }
}
