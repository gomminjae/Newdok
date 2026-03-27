import Foundation

public struct AuthSimpleUser: Identifiable {
    public let id: Int
    public let loginId: String
    public let phoneNumber: String
    public let createdAt: String

    public var maskedLoginId: String {
        let prefix = loginId.prefix(4)
        let starCount = max(0, loginId.count - 4)
        let stars = String(repeating: "*", count: starCount)
        return "\(prefix)\(stars)"
    }

    public var formattedCreatedAt: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = isoFormatter.date(from: createdAt) else {
            return createdAt
        }
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "ko_KR")
        displayFormatter.dateFormat = "yyyy.MM.dd"
        return "\(displayFormatter.string(from: date)) 가입"
    }

    public init(
        id: Int,
        loginId: String,
        phoneNumber: String,
        createdAt: String
    ) {
        self.id = id
        self.loginId = loginId
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
    }
}
