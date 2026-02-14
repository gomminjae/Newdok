//
//  ProfileUseCaseImpl.swift
//  Domain
//
//  Created by 권민재 on 2/14/26.
//

import Foundation
import Shared

public final class ProfileUseCaseImpl: ProfileUseCase {

    private let userUseCase: UserUseCase

    public init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
    }

    public func fetchProfile() async throws -> User {
        let user = try await userUseCase.getProfile()

        // 사용자 정보 로컬 저장소 업데이트
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

    public func updateNickname(_ nickname: String) async throws {
        _ = try await userUseCase.updateNickname(nickname)

        // 로컬 저장소 업데이트
        if var userInfo = UserInfoStore.shared.load() {
            userInfo = UserInfo(
                id: userInfo.id,
                loginId: userInfo.loginId,
                phoneNumber: userInfo.phoneNumber,
                subscribeEmail: userInfo.subscribeEmail,
                nickname: nickname,
                birthYear: userInfo.birthYear,
                gender: userInfo.gender,
                createdAt: userInfo.createdAt,
                industryId: userInfo.industryId,
                interestIds: userInfo.interestIds
            )
            UserInfoStore.shared.save(userInfo)
        }
    }

    public func updateIndustry(_ industryId: Int) async throws {
        try await userUseCase.updateIndustry(industryId)

        // 로컬 저장소 업데이트
        if var userInfo = UserInfoStore.shared.load() {
            userInfo = UserInfo(
                id: userInfo.id,
                loginId: userInfo.loginId,
                phoneNumber: userInfo.phoneNumber,
                subscribeEmail: userInfo.subscribeEmail,
                nickname: userInfo.nickname,
                birthYear: userInfo.birthYear,
                gender: userInfo.gender,
                createdAt: userInfo.createdAt,
                industryId: industryId,
                interestIds: userInfo.interestIds
            )
            UserInfoStore.shared.save(userInfo)
        }
    }

    public func updateInterests(_ interestIds: [Int]) async throws {
        try await userUseCase.updateInterest(interestIds)

        // 로컬 저장소 업데이트
        if var userInfo = UserInfoStore.shared.load() {
            userInfo = UserInfo(
                id: userInfo.id,
                loginId: userInfo.loginId,
                phoneNumber: userInfo.phoneNumber,
                subscribeEmail: userInfo.subscribeEmail,
                nickname: userInfo.nickname,
                birthYear: userInfo.birthYear,
                gender: userInfo.gender,
                createdAt: userInfo.createdAt,
                industryId: userInfo.industryId,
                interestIds: interestIds
            )
            UserInfoStore.shared.save(userInfo)
        }
    }

    public func updatePassword(prevPassword: String, newPassword: String) async throws {
        guard let userInfo = UserInfoStore.shared.load() else {
            throw ProfileError.userNotFound
        }

        try await userUseCase.updatePassword(
            loginId: userInfo.loginId,
            prevPassword: prevPassword,
            newPassword: newPassword
        )
    }
}
