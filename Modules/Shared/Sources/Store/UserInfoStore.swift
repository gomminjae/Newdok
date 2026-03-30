//
//  UserInfoStore.swift
//  Shared
//
//  Created by 권민재 on 5/9/25.
//
import Foundation

public final class UserInfoStore {
    public static let shared = UserInfoStore()

    @KeychainCodableStored(key: "local_user_info")
    private var persisted: UserInfo?

    private var cached: UserInfo?

    public func save(_ user: UserInfo) {
        cached = user
        persisted = user
    }

    public func load() -> UserInfo? {
        if let cached { return cached }
        cached = persisted
        return cached
    }

    public func clear() {
        cached = nil
        persisted = nil
    }
    
    public var hasProfile: Bool {
        guard let user = load() else { return false }
        return !user.nickname.isEmpty &&
        user.industryId != nil &&
        !(user.interestIds.isEmpty)
    }
}
