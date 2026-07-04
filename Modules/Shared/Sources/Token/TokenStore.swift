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

    /// 토큰을 Keychain에 저장/삭제한다.
    /// 저장 성공 시에만 인메모리 상태를 갱신해 세션 상태가 실제 저장 결과와 어긋나지 않게 한다.
    /// - Returns: Keychain 반영 성공 여부. 실패 시 콜러가 로그인 실패로 처리해야 한다.
    @discardableResult
    public func saveAccessToken(_ token: String?) -> Bool {
        if let token {
            let saved = KeychainStorage.save(token, key: Key.accessToken)
            if saved {
                lock.withLock { state in
                    state.token = token
                    state.loaded = true
                }
            }
            return saved
        } else {
            let deleted = KeychainStorage.delete(key: Key.accessToken)
            // 로그아웃/삭제 시 보안상 인메모리는 항상 비운다 (Keychain 삭제 실패와 무관).
            lock.withLock { state in
                state.token = nil
                state.loaded = true
            }
            return deleted
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
