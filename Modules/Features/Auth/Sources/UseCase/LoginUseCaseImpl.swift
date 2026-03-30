import Foundation
import AuthDomain
import Shared

public final class LoginUseCaseImpl: LoginUseCase {
    private let authRepository: AuthRepository
    private let tokenStorage: TokenStorable
    private let userInfoStore: UserInfoStorable
    private let sessionStore: SessionStorable

    public init(
        authRepository: AuthRepository,
        tokenStorage: TokenStorable,
        userInfoStore: UserInfoStorable,
        sessionStore: SessionStorable
    ) {
        self.authRepository = authRepository
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
        self.sessionStore = sessionStore
    }

    public func execute(loginId: String, password: String) async throws -> AuthUser {
        let (user, token) = try await authRepository.login(loginId: loginId, password: password)

        tokenStorage.accessToken = token

        let userInfo = UserInfo(
            id: user.id,
            loginId: user.loginId,
            phoneNumber: user.phoneNumber,
            subscribeEmail: user.subscribeEmail,
            nickname: user.nickname,
            birthYear: user.birthYear,
            gender: user.gender,
            createdAt: user.createdAt,
            industryId: user.industryId,
            interestIds: user.interestIds
        )
        userInfoStore.save(userInfo)
        sessionStore.saveLoginSession(
            nickname: user.nickname,
            email: user.subscribeEmail ?? ""
        )

        return user
    }
}
