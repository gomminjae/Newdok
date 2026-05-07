//
//  TokenStorage.swift
//  Shared
//
//  Created by 권민재 on 4/8/25.
//

import Foundation

public enum TokenStorage {
    @UserDefault("accessToken", default: nil)
    public static var accessToken: String?

    @UserDefault("hasCompletedOnboarding", default: false)
    public static var hasCompletedOnboarding: Bool

    @UserDefault("hideSubscribeStatePopupDate", default: nil)
    public static var hideSubscribeStatePopupDate: Date?

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
