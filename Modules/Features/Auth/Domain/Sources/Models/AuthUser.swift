import Foundation

public struct AuthUser {
    public let id: Int
    public let subscribeEmail: String?
    public let nickname: String
    public let birthYear: String
    public let gender: String
    public let createdAt: String
    public let industryId: Int?
    public let interestIds: [Int]

    public init(
        id: Int,
        subscribeEmail: String?,
        nickname: String,
        birthYear: String,
        gender: String,
        createdAt: String,
        industryId: Int?,
        interestIds: [Int]
    ) {
        self.id = id
        self.subscribeEmail = subscribeEmail
        self.nickname = nickname
        self.birthYear = birthYear
        self.gender = gender
        self.createdAt = createdAt
        self.industryId = industryId
        self.interestIds = interestIds
    }
}
