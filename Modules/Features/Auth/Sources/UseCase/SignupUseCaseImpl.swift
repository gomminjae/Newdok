import Foundation
import AuthDomain
import Shared

public final class SignupUseCaseImpl: SignupUseCase {
    private let authRepository: AuthRepository
    private let loginUseCase: LoginUseCase

    public init(authRepository: AuthRepository, loginUseCase: LoginUseCase) {
        self.authRepository = authRepository
        self.loginUseCase = loginUseCase
    }

    public func execute(request: AuthSignupRequest) async throws -> AuthUser {
        let trimmedNickname = request.nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. 회원가입 API 호출
        let result = try await authRepository.signup(
            loginId: request.loginId,
            password: request.password,
            phoneNumber: request.phoneNumber,
            nickname: trimmedNickname,
            birthYear: request.birthYear,
            gender: request.gender
        )

        // 2. 토큰 저장
        TokenStorage.accessToken = result.accessToken

        // 3. 사용자 정보 저장
        let userInfo = UserInfo(
            id: result.user.id,
            loginId: result.user.loginId,
            phoneNumber: result.user.phoneNumber,
            subscribeEmail: result.user.subscribeEmail,
            nickname: result.user.nickname,
            birthYear: result.user.birthYear,
            gender: result.user.gender,
            createdAt: result.user.createdAt,
            industryId: result.user.industryId,
            interestIds: result.user.interestIds
        )
        UserInfoStore.shared.save(userInfo)

        // 4. 자동 로그인 시도
        do {
            let loginUser = try await loginUseCase.execute(
                loginId: request.loginId,
                password: request.password
            )
            return loginUser
        } catch {
            // 로그인 실패해도 회원가입은 성공했으므로 기본 상태 유지
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(false, forKey: "isGuest")
            UserDefaults.standard.set(result.user.nickname, forKey: "nickname")
            return result.user
        }
    }
}
