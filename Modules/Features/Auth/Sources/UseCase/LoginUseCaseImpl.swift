//
//  LoginUseCaseImpl.swift
//  Domain
//
//  Created by 권민재 on 2/14/26.
//

import Foundation
import AuthDomain
import Shared

public final class LoginUseCaseImpl: LoginUseCase {
    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute(loginId: String, password: String) async throws -> AuthUser {
        let (user, token) = try await authRepository.login(loginId: loginId, password: password)

        // 토큰 저장
        TokenStorage.accessToken = token

        // 사용자 정보 저장
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
        UserInfoStore.shared.save(userInfo)

        return user
    }
}
