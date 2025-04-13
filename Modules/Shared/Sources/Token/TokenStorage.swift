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
}
