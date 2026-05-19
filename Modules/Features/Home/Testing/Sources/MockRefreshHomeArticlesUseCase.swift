import Foundation
import HomeDomain

public final class MockRefreshHomeArticlesUseCase: RefreshHomeArticlesUseCase {
    public var error: Error?
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws {
        executeCallCount += 1
        if let error { throw error }
    }
}
