//
//  UserInfo.swift
//  Shared
//
//  Created by 권민재 on 5/9/25.
//

public struct UserInfo: Sendable {
    public var id: Int
    public var subscribeEmail: String?
    public var nickname: String
    public var birthYear: String
    public var gender: String
    public var createdAt: String
    public var industryId: Int?
    public var interestIds: [Int]

    public init(
        id: Int,
        subscribeEmail: String? = nil,
        nickname: String,
        birthYear: String,
        gender: String,
        createdAt: String,
        industryId: Int? = nil,
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
