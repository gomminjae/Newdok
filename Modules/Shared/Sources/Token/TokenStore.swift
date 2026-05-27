import Foundation
import os

public final class TokenStore: TokenStorageProtocol, Sendable {
    public static let shared = TokenStore()

    private enum Key {
        static let accessToken = "accessToken"
    }

    private struct State {
        var loaded = false
        var token: String?
    }

    private let lock = OSAllocatedUnfairLock(initialState: State())

    private init() {}

    public var accessToken: String? {
        lock.withLock { state in
            if !state.loaded {
                state.token = KeychainStorage.read(key: Key.accessToken)
                state.loaded = true
            }
            return state.token
        }
    }

    public var hasValidToken: Bool {
        guard let token = accessToken else { return false }
        return !token.isEmpty
    }

    public func saveAccessToken(_ token: String?) {
        lock.withLock { state in
            state.token = token
            state.loaded = true
        }
        if let token {
            KeychainStorage.save(token, key: Key.accessToken)
        } else {
            KeychainStorage.delete(key: Key.accessToken)
        }
    }

    public func clear() {
        saveAccessToken(nil)
    }

    public func migrateTokenIfNeeded() {
        guard let legacyToken = UserDefaults.standard.string(forKey: Key.accessToken) else { return }
        saveAccessToken(legacyToken)
        guard KeychainStorage.read(key: Key.accessToken) == legacyToken else { return }
        UserDefaults.standard.removeObject(forKey: Key.accessToken)
    }
}
