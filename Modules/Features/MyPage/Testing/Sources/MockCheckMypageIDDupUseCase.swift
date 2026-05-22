import Foundation
import MypageDomain

public final class MockCheckMypageIDDupUseCase: CheckMypageIDDupUseCase {
    public var result: Result<MypageIDCheckResult, Error> = .success(.notFound)
    public private(set) var executedLoginId: String?

    public init() {}

    public func execute(_ loginId: String) async throws -> MypageIDCheckResult {
        executedLoginId = loginId
        return try result.get()
    }
}
