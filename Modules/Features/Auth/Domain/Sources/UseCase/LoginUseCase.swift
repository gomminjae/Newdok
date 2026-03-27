import Foundation

public protocol LoginUseCase {
    func execute(loginId: String, password: String) async throws -> AuthUser
}
