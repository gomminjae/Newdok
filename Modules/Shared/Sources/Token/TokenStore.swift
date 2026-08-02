import Foundation
import Synchronization

public final class TokenStore: TokenStorageProtocol, Sendable {
    public static let shared = TokenStore()

    private enum State: Sendable {
        case unloaded
        case missing
        case available(String)
    }

    private let state = Mutex<State>(.unloaded)

    private init() {}

    public var accessToken: String? {
        state.withLock { state in
            switch state {
            case .unloaded:
                guard let token = KeychainStorage.read(item: .accessToken) else {
                    state = .missing
                    return nil
                }
                state = .available(token)
                return token
            case .missing:
                return nil
            case let .available(token):
                return token
            }
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
        state.withLock { state in
            if let token {
                guard KeychainStorage.save(token, item: .accessToken) else {
                    return false
                }
                state = .available(token)
                return true
            }

            let deleted = KeychainStorage.delete(item: .accessToken)
            // 로그아웃/삭제 시 보안상 인메모리는 항상 비운다 (Keychain 삭제 실패와 무관).
            state = .missing
            return deleted
        }
    }

    public func clear() {
        saveAccessToken(nil)
    }

    public func migrateTokenIfNeeded() {
        let legacyKey = KeychainItem.accessToken.rawValue
        guard let legacyToken = UserDefaults.standard.string(forKey: legacyKey) else { return }
        saveAccessToken(legacyToken)
        guard KeychainStorage.read(item: .accessToken) == legacyToken else { return }
        UserDefaults.standard.removeObject(forKey: legacyKey)
    }
}
