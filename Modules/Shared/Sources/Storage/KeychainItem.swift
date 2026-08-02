import Foundation
import Security

/// Keychain에 저장하는 항목의 식별자.
/// 호출부에서 임의의 문자열 키를 전달하지 못하도록 지원 항목을 명시한다.
public enum KeychainItem: String, Sendable {
    case accessToken
}

/// Keychain Generic Password 항목 접근 헬퍼.
/// 서비스 단위로 key-value 저장/조회/삭제를 제공한다.
public enum KeychainStorage {
    public static let defaultService = Bundle.main.bundleIdentifier ?? "com.newdok"

    public static func read(item: KeychainItem, service: String = defaultService) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: item.rawValue,
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

    @discardableResult
    public static func save(_ value: String, item: KeychainItem, service: String = defaultService) -> Bool {
        guard let data = value.data(using: .utf8) else {
            logError("save: \(item.rawValue) UTF-8 인코딩 실패", category: .token)
            return false
        }

        let itemQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: item.rawValue
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let updateStatus = SecItemUpdate(
            itemQuery as CFDictionary,
            attributes as CFDictionary
        )

        if updateStatus == errSecSuccess {
            return true
        }

        guard updateStatus == errSecItemNotFound else {
            logError("save: \(item.rawValue) 갱신 실패 (OSStatus \(updateStatus))", category: .token)
            return false
        }

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: item.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        if addStatus == errSecSuccess {
            return true
        }

        // 조회와 추가 사이 다른 실행 흐름이 먼저 항목을 만들었다면 마지막으로 갱신한다.
        if addStatus == errSecDuplicateItem {
            let retryStatus = SecItemUpdate(
                itemQuery as CFDictionary,
                attributes as CFDictionary
            )
            guard retryStatus == errSecSuccess else {
                logError("save: \(item.rawValue) 재갱신 실패 (OSStatus \(retryStatus))", category: .token)
                return false
            }
            return true
        }

        logError("save: \(item.rawValue) 추가 실패 (OSStatus \(addStatus))", category: .token)
        return false
    }

    @discardableResult
    public static func delete(item: KeychainItem, service: String = defaultService) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: item.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            logError("delete: \(item.rawValue) 실패 (OSStatus \(status))", category: .token)
            return false
        }
        return true
    }
}
