import Foundation
import AuthDomain
import Shared

public final class SignupUseCaseImpl: SignupUseCase {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(request: AuthSignupRequest) async throws -> AuthUser {
        let trimmedNickname = request.nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        let result = try await authRepository.signup(
            signupToken: request.signupToken,
            nickname: trimmedNickname,
            birthYear: request.birthYear,
            gender: request.gender,
            agreements: request.agreements
        )

        return result.user
    }
}
