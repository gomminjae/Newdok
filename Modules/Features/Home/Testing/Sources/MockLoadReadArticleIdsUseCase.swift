import Foundation
import HomeDomain
import Synchronization

public final class MockLoadReadArticleIdsUseCase: LoadReadArticleIdsUseCase {
    private let storedResult = Mutex<Set<Int>>([])

    public var result: Set<Int> {
        get { storedResult.withLock { $0 } }
        set { storedResult.withLock { $0 = newValue } }
    }

    public init() {}

    public func execute() -> Set<Int> {
        result
    }
}
