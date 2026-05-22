import Foundation
import MypageDomain

public final class MockCheckMypagePhoneNumberUseCase: CheckMypagePhoneNumberUseCase {
    public var result: Result<[MypageSimpleUser], Error> = .success([])
    public private(set) var executedPhoneNumber: String?

    public init() {}

    public func execute(_ phoneNumber: String) async throws -> [MypageSimpleUser] {
        executedPhoneNumber = phoneNumber
        return try result.get()
    }
}
