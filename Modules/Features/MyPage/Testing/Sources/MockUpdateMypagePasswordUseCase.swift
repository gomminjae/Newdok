import Foundation
import MypageDomain

public final class MockUpdateMypagePasswordUseCase: UpdateMypagePasswordUseCase {
    public var result: Result<Void, Error> = .success(())
    public private(set) var executeCallCount = 0

    public init() {}

    public func execute(prevPassword: String, newPassword: String) async throws {
        executeCallCount += 1
        try result.get()
    }
}
