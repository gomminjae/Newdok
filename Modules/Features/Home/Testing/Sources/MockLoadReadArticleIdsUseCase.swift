import Foundation
import HomeDomain

public final class MockLoadReadArticleIdsUseCase: LoadReadArticleIdsUseCase {
    public var result: Set<Int> = []

    public init() {}

    public func execute() -> Set<Int> {
        result
    }
}
