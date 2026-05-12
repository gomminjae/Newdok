//
//  UserInfoStore.swift
//  Shared
//
//  Created by 권민재 on 5/9/25.
//
import Foundation

public final class UserInfoStore: UserInfoStoreProtocol, @unchecked Sendable {
    public static let shared = UserInfoStore()

    @CodableUserDefault("local_user_info", default: nil)
    private var stored: UserInfo?

    private init() {}

    public func save(_ user: UserInfo) {
        stored = user
    }

    public func load() -> UserInfo? {
        stored
    }

    public func clear() {
        stored = nil
    }

    public var hasProfile: Bool {
        guard let user = stored else { return false }
        return !user.nickname.isEmpty &&
            user.industryId != nil &&
            !user.interestIds.isEmpty
    }
}
