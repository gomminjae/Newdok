import Foundation

public enum ReadStatus: Sendable, Equatable {
    case read
    case unread

    public init(serverValue: String) {
        self = serverValue.caseInsensitiveCompare("Read") == .orderedSame ? .read : .unread
    }

    public var isRead: Bool { self == .read }
}
