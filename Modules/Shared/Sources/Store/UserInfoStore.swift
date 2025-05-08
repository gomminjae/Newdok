//
//  UserInfoStore.swift
//  Shared
//
//  Created by 권민재 on 5/9/25.
//
import Foundation

public final class UserInfoStore {
    public static let shared = UserInfoStore()
    private let key = "local_user_info"

    public func save(_ user: UserInfo) {
        let data = try? JSONEncoder().encode(user)
        UserDefaults.standard.set(data, forKey: key)
    }

    public func load() -> UserInfo? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(UserInfo.self, from: data)
    }

    public func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
