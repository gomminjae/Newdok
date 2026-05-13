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
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let hideSubscribeStatePopupDate = "hideSubscribeStatePopupDate"
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

    public static var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: Key.hasCompletedOnboarding) }
        set { UserDefaults.standard.set(newValue, forKey: Key.hasCompletedOnboarding) }
    }

    public static var hideSubscribeStatePopupDate: Date? {
        get { UserDefaults.standard.object(forKey: Key.hideSubscribeStatePopupDate) as? Date }
        set {
            if let date = newValue {
                UserDefaults.standard.set(date, forKey: Key.hideSubscribeStatePopupDate)
            } else {
                UserDefaults.standard.removeObject(forKey: Key.hideSubscribeStatePopupDate)
            }
        }
    }

    /// 기존 UserDefaults 토큰을 Keychain으로 마이그레이션
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

    public static func markOnboardingCompleted() {
        hasCompletedOnboarding = true
    }

    public static func hideSubscribeStatePopupForToday() {
        hideSubscribeStatePopupDate = Date()
    }

    public static var shouldShowSubscribeStatePopup: Bool {
        guard let hideDate = hideSubscribeStatePopupDate else { return true }
        return !Calendar.current.isDate(hideDate, inSameDayAs: Date())
    }
}

// MARK: - Notification Names
public extension Notification.Name {
    static let didReceiveUnauthorized = Notification.Name("didReceiveUnauthorized")
    static let didLoginSuccess = Notification.Name("didLoginSuccess")
    static let showToast = Notification.Name("showToast")
    static let articleStatusChanged = Notification.Name("articleStatusChanged")
}
