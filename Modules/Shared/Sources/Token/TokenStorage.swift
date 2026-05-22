//
//  TokenStorage.swift
//  Shared
//
//  Created by 권민재 on 4/8/25.
//

import Foundation

public enum TokenStorage {
    private enum Key {
        static let accessToken = "accessToken"
    }

    public static var accessToken: String? {
        get { KeychainStorage.read(key: Key.accessToken) }
        set {
            if let value = newValue {
                KeychainStorage.save(value, key: Key.accessToken)
            } else {
                KeychainStorage.delete(key: Key.accessToken)
            }
        }
    }

    public static func migrateTokenIfNeeded() {
        guard let legacyToken = UserDefaults.standard.string(forKey: Key.accessToken) else { return }
        accessToken = legacyToken
        guard accessToken == legacyToken else { return }
        UserDefaults.standard.removeObject(forKey: Key.accessToken)
    }

    public static func clear() {
        accessToken = nil
    }

    public static var hasValidToken: Bool {
        guard let token = accessToken else { return false }
        return !token.isEmpty
    }
}
