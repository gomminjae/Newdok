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
            loginId: request.loginId,
            password: request.password,
            phoneNumber: request.phoneNumber,
            nickname: trimmedNickname,
            birthYear: request.birthYear,
            gender: request.gender
        )

        do {
            let (user, _) = try await authRepository.login(
                loginId: request.loginId,
                password: request.password
            )
            return user
        } catch {
            return result.user
        }
    }
}
