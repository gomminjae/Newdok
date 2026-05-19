import Foundation
import MypageDomain

public final class MockFetchMypageSubscriptionCountUseCase: FetchMypageSubscriptionCountUseCase {
    public var result: Result<Int, Error> = .success(5)
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws -> Int {
        executeCallCount += 1
        return try result.get()
    }
}
