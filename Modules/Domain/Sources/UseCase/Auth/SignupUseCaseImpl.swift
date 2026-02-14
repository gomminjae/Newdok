//
//  SignupUseCaseImpl.swift
//  Domain
//
//  Created by 권민재 on 2/14/26.
//

import Foundation
import Shared

public final class SignupUseCaseImpl: SignupUseCase {

    private let userUseCase: UserUseCase
    private let loginUseCase: LoginUseCase

    public init(userUseCase: UserUseCase, loginUseCase: LoginUseCase) {
        self.userUseCase = userUseCase
        self.loginUseCase = loginUseCase
    }

    public func execute(request: SignupRequest) async throws -> User {
        let trimmedNickname = request.nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. 회원가입 API 호출
        let result = try await userUseCase.signup(
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
            interestIds: result.user.interests.map { $0.id }
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
