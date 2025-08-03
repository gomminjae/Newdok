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
}

// MARK: - Notification Names
public extension Notification.Name {
    static let didReceiveUnauthorized = Notification.Name("didReceiveUnauthorized")
    static let didLoginSuccess = Notification.Name("didLoginSuccess")
}
