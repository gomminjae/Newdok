import Foundation
import AuthDomain
import Shared

public final class LoginUseCaseImpl: LoginUseCase {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(credential: SocialLoginCredential) async throws -> SocialLoginResultType {
        try await authRepository.login(credential: credential)
    }
}
