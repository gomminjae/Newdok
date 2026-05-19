import Foundation
import MypageDomain

public final class MockResetMypagePasswordUseCase: ResetMypagePasswordUseCase {
    public var result: Result<Void, Error> = .success(())
    public private(set) var executedLoginId: String?
    public private(set) var executedNewPassword: String?

    public init() {}

    public func execute(loginId: String, newPassword: String) async throws {
        executedLoginId = loginId
        executedNewPassword = newPassword
        try result.get()
    }
}
