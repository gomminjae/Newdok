//
//  ProfileUseCaseImpl.swift
//  Mypage
//
//  Created by 권민재 on 2/14/26.
//

import Foundation
import MypageDomain
import Shared

public final class ProfileUseCaseImpl: MypageProfileUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func fetchProfile() async throws -> MypageUser {
        try await repository.getProfile()
    }

    public func updateNickname(_ nickname: String) async throws {
        _ = try await repository.updateNickname(nickname)
    }

    public func updateIndustry(_ industryId: Int) async throws {
        try await repository.updateIndustry(industryId)
    }

    public func updateInterests(_ interestIds: [Int]) async throws {
        try await repository.updateInterest(interestIds)
    }

    public func updatePassword(prevPassword: String, newPassword: String) async throws {
        try await repository.updatePassword(prevPassword: prevPassword, newPassword: newPassword)
    }
}
