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
        updateLocalUserInfo { $0.withNickname(nickname) }
    }

    public func updateIndustry(_ industryId: Int) async throws {
        try await userUseCase.updateIndustry(industryId)
        updateLocalUserInfo { $0.withIndustryId(industryId) }
    }

    public func updateInterests(_ interestIds: [Int]) async throws {
        try await userUseCase.updateInterest(interestIds)
        updateLocalUserInfo { $0.withInterestIds(interestIds) }
    }

    // MARK: - Private Helpers

    private func updateLocalUserInfo(_ transform: (UserInfo) -> UserInfo) {
        guard let userInfo = UserInfoStore.shared.load() else { return }
        UserInfoStore.shared.save(transform(userInfo))
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
