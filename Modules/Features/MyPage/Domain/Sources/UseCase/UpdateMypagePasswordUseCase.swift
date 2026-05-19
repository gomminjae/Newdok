import Foundation

public protocol UpdateMypagePasswordUseCase: Sendable {
    func execute(prevPassword: String, newPassword: String) async throws
}
