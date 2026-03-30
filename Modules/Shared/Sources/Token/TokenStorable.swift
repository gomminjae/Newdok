import Foundation

public protocol TokenStorable: AnyObject, Sendable {
    var accessToken: String? { get set }
    func clear()
    var hasValidToken: Bool { get }
}

public final class TokenStorageAdapter: TokenStorable, @unchecked Sendable {
    public static let shared = TokenStorageAdapter()

    public var accessToken: String? {
        get { TokenStorage.accessToken }
        set { TokenStorage.accessToken = newValue }
    }

    public func clear() { TokenStorage.clear() }
    public var hasValidToken: Bool { TokenStorage.hasValidToken }
}
