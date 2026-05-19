import Foundation
import MypageDomain
import Shared

public final class MockCheckMypageIDDupUseCase: CheckMypageIDDupUseCase {
    public var result: Result<CheckResult<MypageSimpleUser>, Error> = .success(.notFound)
    public private(set) var executedLoginId: String?

    public init() {}

    public func execute(_ loginId: String) async throws -> CheckResult<MypageSimpleUser> {
        executedLoginId = loginId
        return try result.get()
    }
}
