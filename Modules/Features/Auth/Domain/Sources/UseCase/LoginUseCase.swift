import Foundation

public protocol LoginUseCase: Sendable {
    func execute(loginId: String, password: String) async throws -> AuthUser
}
