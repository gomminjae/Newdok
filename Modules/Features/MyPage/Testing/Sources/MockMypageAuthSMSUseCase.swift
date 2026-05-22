import Foundation
import MypageDomain

public final class MockMypageAuthSMSUseCase: MypageAuthSMSUseCase {
    public var result: Result<MypageSMSResponse, Error> = .success(MypageSMSResponse(code: 123456))
    public private(set) var executedPhoneNumber: String?

    public init() {}

    public func execute(phoneNumber: String) async throws -> MypageSMSResponse {
        executedPhoneNumber = phoneNumber
        return try result.get()
    }
}
