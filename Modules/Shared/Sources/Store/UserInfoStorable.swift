import Foundation

public protocol UserInfoStorable: AnyObject, Sendable {
    func save(_ user: UserInfo)
    func load() -> UserInfo?
    func clear()
    var hasProfile: Bool { get }
}

extension UserInfoStore: UserInfoStorable, @unchecked Sendable {}
