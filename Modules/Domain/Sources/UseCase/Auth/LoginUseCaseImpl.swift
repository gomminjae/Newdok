//
//  LoginUseCaseImpl.swift
//  Domain
//
//  Created by 권민재 on 2/14/26.
//

import Foundation
import Shared

public final class LoginUseCaseImpl: LoginUseCase {
    private let userUseCase: UserUseCase

    public init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
    }

    public func execute(loginId: String, password: String) async throws -> User {
        let (user, token) = try await userUseCase.login(loginId: loginId, password: password)

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
            interestIds: user.interests.map { $0.id }
        )
        UserInfoStore.shared.save(userInfo)

        return user
    }
}
