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
        get {
            UserDefaults.standard.string(forKey: Key.accessToken)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: Key.accessToken)
            } else {
                UserDefaults.standard.removeObject(forKey: Key.accessToken)
            }
        }
    }

    public static func clear() {
        UserDefaults.standard.removeObject(forKey: Key.accessToken)
    }
    
    public static var hasValidToken: Bool {
        return accessToken != nil && !accessToken!.isEmpty
    }
    
    public static var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: Key.hasCompletedOnboarding)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.hasCompletedOnboarding)
        }
    }
    
    public static func markOnboardingCompleted() {
        hasCompletedOnboarding = true
    }
    
    public static var hideSubscribeStatePopupDate: Date? {
        get {
            UserDefaults.standard.object(forKey: Key.hideSubscribeStatePopupDate) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.hideSubscribeStatePopupDate)
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
