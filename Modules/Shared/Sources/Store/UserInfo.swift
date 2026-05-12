//
//  UserInfo.swift
//  Shared
//
//  Created by 권민재 on 5/9/25.
//

public struct UserInfo: Codable {
    public var id: Int
    public var loginId: String
    public var phoneNumber: String
    public var subscribeEmail: String?
    public var nickname: String
    public var birthYear: String
    public var gender: String
    public var createdAt: String
    public var industryId: Int?
    public var interestIds: [Int]

    public init(
        id: Int,
        loginId: String,
        phoneNumber: String,
        subscribeEmail: String? = nil,
        nickname: String,
        birthYear: String,
        gender: String,
        createdAt: String,
        industryId: Int? = nil,
        interestIds: [Int]
    ) {
        self.id = id
        self.loginId = loginId
        self.phoneNumber = phoneNumber
        self.subscribeEmail = subscribeEmail
        self.nickname = nickname
        self.birthYear = birthYear
        self.gender = gender
        self.createdAt = createdAt
        self.industryId = industryId
        self.interestIds = interestIds
    }
}
