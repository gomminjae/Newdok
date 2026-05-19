import Foundation
import MypageDomain

public final class MockMypageWithdrawUseCase: MypageWithdrawUseCase {
    public var result: Result<Void, Error> = .success(())
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute() async throws {
        executeCallCount += 1
        try result.get()
    }
}
