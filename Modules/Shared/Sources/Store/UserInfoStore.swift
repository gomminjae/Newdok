//
//  UserInfoStore.swift
//  Shared
//
//  Created by 권민재 on 5/9/25.
//
import Foundation

public final class UserInfoStore: UserInfoStoreProtocol, Sendable {
    public static let shared = UserInfoStore()
    private static let key = "local_user_info"

    private init() {}

    public func save(_ user: UserInfo) {
        guard let data = try? PropertyListEncoder().encode(UserInfoDTO(from: user)) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }

    public func load() -> UserInfo? {
        guard let data = UserDefaults.standard.data(forKey: Self.key) else { return nil }
        return (try? PropertyListDecoder().decode(UserInfoDTO.self, from: data))?.toDomain()
    }

    public func clear() {
        UserDefaults.standard.removeObject(forKey: Self.key)
    }

    public var hasProfile: Bool {
        guard let user = load() else { return false }
        return !user.nickname.isEmpty &&
            user.industryId != nil &&
            !user.interestIds.isEmpty
    }
}

private struct UserInfoDTO: Codable {
    let id: Int
    let loginId: String
    let phoneNumber: String
    let subscribeEmail: String?
    let nickname: String
    let birthYear: String
    let gender: String
    let createdAt: String
    let industryId: Int?
    let interestIds: [Int]

    init(from domain: UserInfo) {
        self.id = domain.id
        self.loginId = domain.loginId
        self.phoneNumber = domain.phoneNumber
        self.subscribeEmail = domain.subscribeEmail
        self.nickname = domain.nickname
        self.birthYear = domain.birthYear
        self.gender = domain.gender
        self.createdAt = domain.createdAt
        self.industryId = domain.industryId
        self.interestIds = domain.interestIds
    }

    func toDomain() -> UserInfo {
        UserInfo(
            id: id,
            loginId: loginId,
            phoneNumber: phoneNumber,
            subscribeEmail: subscribeEmail,
            nickname: nickname,
            birthYear: birthYear,
            gender: gender,
            createdAt: createdAt,
            industryId: industryId,
            interestIds: interestIds
        )
    }
}
