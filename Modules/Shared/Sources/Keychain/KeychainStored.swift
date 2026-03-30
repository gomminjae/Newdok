//
//  KeychainStored.swift
//  Shared
//
//  Created by 권민재 on 3/30/26.
//

import Foundation
import Security

@propertyWrapper
public struct KeychainStored {
    private let key: String
    private let service: String

    public init(key: String, service: String = "com.newdok.app") {
        self.key = key
        self.service = service
    }

    public var wrappedValue: String? {
        get {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            guard status == errSecSuccess,
                  let data = result as? Data else { return nil }
            return String(data: data, encoding: .utf8)
        }
        set {
            delete()
            guard let newValue,
                  let data = newValue.data(using: .utf8) else { return }
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    private func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
