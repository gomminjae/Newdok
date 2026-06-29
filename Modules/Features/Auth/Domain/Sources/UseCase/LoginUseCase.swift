import Foundation

public protocol LoginUseCase: Sendable {
    func execute(provider: SocialProvider, idToken: String) async throws -> AuthUser
}
