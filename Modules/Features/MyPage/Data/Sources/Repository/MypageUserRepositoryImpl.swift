//
//  MypageUserRepositoryImpl.swift
//  MypageData
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation
import MypageDomain
import Core
import Moya
import Shared

public final class MypageUserRepositoryImpl: MypageUserRepository {
    private let provider: MoyaProvider<UserAPI>

    public init(provider: MoyaProvider<UserAPI>) {
        self.provider = provider
    }

    public func getProfile() async throws -> MypageUser {
        let response: MypageUserDTO = try await provider.asyncRequest(.profile)
        return response.toDomain()
    }

    public func updateNickname(_ nickname: String) async throws -> MypageNicknameResponse {
        let response: MypageNicknameResponseDTO = try await provider.asyncRequest(.updateNickname(nickname: nickname))
        return response.toDomain()
    }

    public func updatePassword(loginId: String, prevPassword: String, newPassword: String) async throws {
        _ = try await provider.asyncVoidRequest(.updatePassword(loginId: loginId, prevPassword: prevPassword, password: newPassword))
    }

    public func updateInterest(_ interestsId: [Int]) async throws {
        _ = try await provider.asyncVoidRequest(.updateInterest(interestsId: interestsId))
    }

    public func updateIndustry(_ industryId: Int) async throws {
        _ = try await provider.asyncVoidRequest(.updateIndustry(industryId: industryId))
    }

    public func updatePhoneNumber(_ phoneNumber: String) async throws {
        _ = try await provider.asyncVoidRequest(.updatePhoneNumber(phoneNumber: phoneNumber))
    }

    public func authSMS(phoneNumber: String) async throws -> MypageSMSResponse {
        let response: MypageSMSResponseDTO = try await provider.asyncRequest(.authSMS(phoneNumber: phoneNumber))
        return response.toDomain()
    }

    public func checkPhoneNumber(_ phoneNumber: String) async throws -> [MypageSimpleUser] {
        do {
            let response: [MypageSimpleUserDTO] = try await provider.asyncRequest(.checkPhoneNumber(phoneNumber: phoneNumber))
            return response.compactMap { $0.toDomain() }
        } catch let error as NetworkError {
            if case .serverError(let statusCode, _) = error, statusCode == 400 {
                return []
            } else {
                throw error
            }
        } catch {
            throw error
        }
    }

    public func checkIDDup(_ loginId: String) async throws -> CheckResult<MypageSimpleUser> {
        let result = try await provider.safeCheckRequest(.checkIDDup(loginId: loginId), decodeTo: MypageSimpleUserDTO.self)
        switch result {
        case .exists(let dto):
            return .exists(dto.toDomain())
        case .notFound:
            return .notFound
        }
    }

    public func withdraw() async throws {
        _ = try await provider.asyncVoidRequest(.withdraw)
    }
}
