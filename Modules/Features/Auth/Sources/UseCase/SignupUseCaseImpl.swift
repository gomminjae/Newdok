import Foundation
import AuthDomain
import Shared

public final class SignupUseCaseImpl: SignupUseCase {
    private let authRepository: AuthRepository
    private let loginUseCase: LoginUseCase
    private let tokenStorage: TokenStorable
    private let userInfoStore: UserInfoStorable
    private let sessionStore: SessionStorable

    public init(
        authRepository: AuthRepository,
        loginUseCase: LoginUseCase,
        tokenStorage: TokenStorable,
        userInfoStore: UserInfoStorable,
        sessionStore: SessionStorable
    ) {
        self.authRepository = authRepository
        self.loginUseCase = loginUseCase
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
        self.sessionStore = sessionStore
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

        tokenStorage.accessToken = result.accessToken

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
        userInfoStore.save(userInfo)

        do {
            let loginUser = try await loginUseCase.execute(
                loginId: request.loginId,
                password: request.password
            )
            return loginUser
        } catch {
            sessionStore.saveLoginSession(
                nickname: result.user.nickname,
                email: result.user.subscribeEmail ?? ""
            )
            return result.user
        }
    }

    public func checkPhoneNumber(_ phoneNumber: String) async throws -> [AuthSimpleUser] {
        try await authRepository.checkPhoneNumber(phoneNumber)
    }

    public func sendSMS(phoneNumber: String) async throws -> AuthSMSResponse {
        try await authRepository.authSMS(phoneNumber: phoneNumber)
    }

    public func checkIDDuplicate(_ loginId: String) async throws -> CheckResult<AuthSimpleUser> {
        try await authRepository.checkIDDup(loginId)
    }

    public func fetchRecommendations(industryId: String, interestIds: [String]) async throws -> [AuthRecommendedBrand] {
        try await authRepository.preInvestigate(industryId: industryId, interestIds: interestIds)
    }
}
