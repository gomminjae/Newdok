//
//  TokenStorageWrapper.swift
//  Shared
//
//  Created by Claude on 5/9/26.
//

import Foundation

public final class TokenStorageWrapper: TokenStorageProtocol, @unchecked Sendable {
    public static let shared = TokenStorageWrapper()

    private init() {}

    public var accessToken: String? {
        TokenStorage.accessToken
    }

    public var hasValidToken: Bool {
        TokenStorage.hasValidToken
    }

    public func saveAccessToken(_ token: String?) {
        TokenStorage.accessToken = token
    }

    public func clear() {
        TokenStorage.clear()
    }

    public func migrateTokenIfNeeded() {
        TokenStorage.migrateTokenIfNeeded()
    }
}
