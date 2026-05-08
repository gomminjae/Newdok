import Foundation
import Security

@propertyWrapper
public struct KeychainItem {
    private let key: String
    private let service: String

    public init(_ key: String, service: String = Bundle.main.bundleIdentifier ?? "com.newdok") {
        self.key = key
        self.service = service
    }

    public var wrappedValue: String? {
        get { read() }
        set {
            if let value = newValue {
                save(value)
            } else {
                delete()
            }
        }
    }

    private func read() -> String? {
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
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8)
        else { return nil }

        return string
    }

    private func save(_ value: String) {
        guard let data = value.data(using: .utf8) else { return }

        // 기존 항목 삭제 후 추가
        delete()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        SecItemAdd(query as CFDictionary, nil)
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
