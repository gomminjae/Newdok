//
//  TokenStorage.swift
//  Shared
//
//  Created by 권민재 on 4/8/25.
//

import Foundation

public enum TokenStorage {
    @KeychainStored(key: "accessToken")
    public static var accessToken: String?

    public static func clear() {
        accessToken = nil
    }

    public static var hasValidToken: Bool {
        guard let token = accessToken else { return false }
        return !token.isEmpty
    }
    
    public static var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding")
        }
    }

    public static func markOnboardingCompleted() {
        hasCompletedOnboarding = true
    }

    public static var hideSubscribeStatePopupDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "hideSubscribeStatePopupDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hideSubscribeStatePopupDate")
        }
    }
    
    public static func hideSubscribeStatePopupForToday() {
        hideSubscribeStatePopupDate = Date()
    }
    
    public static var shouldShowSubscribeStatePopup: Bool {
        guard let hideDate = hideSubscribeStatePopupDate else { return true }
        
        let calendar = Calendar.current
        let today = Date()
        
        // 오늘 날짜와 저장된 날짜가 같은지 확인
        return !calendar.isDate(hideDate, inSameDayAs: today)
    }
}

// MARK: - Notification Names
public extension Notification.Name {
    static let didReceiveUnauthorized = Notification.Name("didReceiveUnauthorized")
    static let didLoginSuccess = Notification.Name("didLoginSuccess")
    static let showToast = Notification.Name("showToast")
    static let articleStatusChanged = Notification.Name("articleStatusChanged")
}
