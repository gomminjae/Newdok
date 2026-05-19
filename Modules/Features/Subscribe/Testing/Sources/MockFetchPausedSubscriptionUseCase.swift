import Foundation
import SubscribeDomain

public final class MockFetchPausedSubscriptionUseCase: FetchPausedSubscriptionUseCase {
    public var result: Result<[SubscribeNewsletter], Error> = .success([])
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws -> [SubscribeNewsletter] {
        executeCallCount += 1
        return try result.get()
    }
}
