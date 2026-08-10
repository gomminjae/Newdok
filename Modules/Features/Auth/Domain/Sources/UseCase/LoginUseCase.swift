import Foundation

public protocol LoginUseCase: Sendable {
    func execute(credential: SocialLoginCredential) async throws -> SocialLoginResultType
}
