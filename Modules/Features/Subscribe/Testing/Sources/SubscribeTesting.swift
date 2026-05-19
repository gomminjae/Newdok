import Foundation
import SubscribeDomain

public final class MockFetchActiveSubscriptionUseCase: FetchActiveSubscriptionUseCase {
    public var result: Result<[SubscribeNewsletter], Error> = .success([])
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws -> [SubscribeNewsletter] {
        executeCallCount += 1
        return try result.get()
    }
}

public final class MockFetchPausedSubscriptionUseCase: FetchPausedSubscriptionUseCase {
    public var result: Result<[SubscribeNewsletter], Error> = .success([])
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws -> [SubscribeNewsletter] {
        executeCallCount += 1
        return try result.get()
    }
}

public final class MockPauseSubscriptionUseCase: PauseSubscriptionUseCase {
    public var result: Result<Void, Error> = .success(())
    public private(set) var executedNewsletterId: String?

    public init() {}

    public func execute(newsletterId: String) async throws {
        executedNewsletterId = newsletterId
        try result.get()
    }
}

public final class MockResumeSubscriptionUseCase: ResumeSubscriptionUseCase {
    public var result: Result<Void, Error> = .success(())
    public private(set) var executedNewsletterId: String?

    public init() {}

    public func execute(newsletterId: String) async throws {
        executedNewsletterId = newsletterId
        try result.get()
    }
}
