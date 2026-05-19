import Foundation
import Shared

public protocol MypageAuthSMSUseCase: Sendable {
    func execute(phoneNumber: String) async throws -> MypageSMSResponse
}
