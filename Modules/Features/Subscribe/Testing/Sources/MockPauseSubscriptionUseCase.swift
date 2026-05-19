import Foundation
import SubscribeDomain

public final class MockPauseSubscriptionUseCase: PauseSubscriptionUseCase {
    public var result: Result<Void, Error> = .success(())
    public private(set) var executedNewsletterId: String?

    public init() {}

    public func execute(newsletterId: String) async throws {
        executedNewsletterId = newsletterId
        try result.get()
    }
}
