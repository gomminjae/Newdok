//
//  KeychainCodableStored.swift
//  Shared
//
//  Created by 권민재 on 3/30/26.
//

import Foundation
import Security

@propertyWrapper
public struct KeychainCodableStored<T: Codable> {
    private let key: String
    private let service: String

    public init(key: String, service: String = "com.newdok.app") {
        self.key = key
        self.service = service
    }

    public var wrappedValue: T? {
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
            return try? JSONDecoder().decode(T.self, from: data)
        }
        set {
            delete()
            guard let newValue,
                  let data = try? JSONEncoder().encode(newValue) else { return }
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
