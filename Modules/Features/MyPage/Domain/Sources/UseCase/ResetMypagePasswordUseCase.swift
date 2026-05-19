import Foundation

public protocol ResetMypagePasswordUseCase: Sendable {
    func execute(loginId: String, newPassword: String) async throws
}
