import Foundation
import MypageDomain

public final class MockUpdateMypagePhoneNumberUseCase: UpdateMypagePhoneNumberUseCase {
    public var result: Result<Void, Error> = .success(())
    public private(set) var executedPhoneNumber: String?

    public init() {}

    public func execute(_ phoneNumber: String) async throws {
        executedPhoneNumber = phoneNumber
        try result.get()
    }
}
