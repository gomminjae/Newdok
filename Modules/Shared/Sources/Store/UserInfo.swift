//
//  UserInfo.swift
//  Shared
//
//  Created by 권민재 on 5/9/25.
//

public struct UserInfo: Codable {
    public let id: Int
    public let loginId: String
    public let phoneNumber: String
    public let subscribeEmail: String?
    public let nickname: String
    public let birthYear: String
    public let gender: String
    public let createdAt: String
    public let industryId: Int?
    public let interestIds: [Int]
    
    public init(id: Int, loginId: String, phoneNumber: String, subscribeEmail: String?, nickname: String, birthYear: String, gender: String, createdAt: String, industryId: Int?, interestIds: [Int]) {
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

    // MARK: - Immutable Update Helpers

    public func withNickname(_ nickname: String) -> UserInfo {
        UserInfo(id: id, loginId: loginId, phoneNumber: phoneNumber, subscribeEmail: subscribeEmail, nickname: nickname, birthYear: birthYear, gender: gender, createdAt: createdAt, industryId: industryId, interestIds: interestIds)
    }

    public func withIndustryId(_ industryId: Int) -> UserInfo {
        UserInfo(id: id, loginId: loginId, phoneNumber: phoneNumber, subscribeEmail: subscribeEmail, nickname: nickname, birthYear: birthYear, gender: gender, createdAt: createdAt, industryId: industryId, interestIds: interestIds)
    }

    public func withInterestIds(_ interestIds: [Int]) -> UserInfo {
        UserInfo(id: id, loginId: loginId, phoneNumber: phoneNumber, subscribeEmail: subscribeEmail, nickname: nickname, birthYear: birthYear, gender: gender, createdAt: createdAt, industryId: industryId, interestIds: interestIds)
    }
}
