//
//  MypageUserUseCaseImpl.swift
//  MypageDomain
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation
import Shared

public final class MypageUserUseCaseImpl: MypageUserUseCase {
    private let repository: MypageUserRepository

    public init(repository: MypageUserRepository) {
        self.repository = repository
    }

    public func getProfile() async throws -> MypageUser {
        try await repository.getProfile()
    }

    public func updateNickname(_ nickname: String) async throws -> MypageNicknameResponse {
        try await repository.updateNickname(nickname)
    }

    public func updatePassword(loginId: String, prevPassword: String, newPassword: String) async throws {
        try await repository.updatePassword(loginId: loginId, prevPassword: prevPassword, newPassword: newPassword)
    }

    public func updateInterest(_ interestsId: [Int]) async throws {
        try await repository.updateInterest(interestsId)
    }

    public func updateIndustry(_ industryId: Int) async throws {
        try await repository.updateIndustry(industryId)
    }

    public func updatePhoneNumber(_ phoneNumber: String) async throws {
        try await repository.updatePhoneNumber(phoneNumber)
    }

    public func authSMS(phoneNumber: String) async throws -> MypageSMSResponse {
        try await repository.authSMS(phoneNumber: phoneNumber)
    }

    public func checkPhoneNumber(_ phoneNumber: String) async throws -> [MypageSimpleUser] {
        try await repository.checkPhoneNumber(phoneNumber)
    }

    public func checkIDDup(_ loginId: String) async throws -> CheckResult<MypageSimpleUser> {
        try await repository.checkIDDup(loginId)
    }

    public func withdraw() async throws {
        try await repository.withdraw()
    }
}
