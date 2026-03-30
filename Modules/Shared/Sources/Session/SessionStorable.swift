import Foundation

public protocol SessionStorable: AnyObject, Sendable {
    func saveLoginSession(nickname: String, email: String)
    func saveGuestSession()
    func clearSession()
}

public final class SessionStore: SessionStorable, @unchecked Sendable {
    public static let shared = SessionStore()

    private enum Key {
        static let isLoggedIn = "isLoggedIn"
        static let isGuest = "isGuest"
        static let nickname = "nickname"
        static let email = "email"
    }

    public func saveLoginSession(nickname: String, email: String) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: Key.isLoggedIn)
        defaults.set(false, forKey: Key.isGuest)
        defaults.set(nickname, forKey: Key.nickname)
        defaults.set(email, forKey: Key.email)
    }

    public func saveGuestSession() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: Key.isLoggedIn)
        defaults.set(true, forKey: Key.isGuest)
    }

    public func clearSession() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Key.isLoggedIn)
        defaults.removeObject(forKey: Key.isGuest)
        defaults.removeObject(forKey: Key.nickname)
        defaults.removeObject(forKey: Key.email)
    }
}
