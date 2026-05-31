//
//  MypageUser.swift
//  MypageDomain
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation

public struct MypageUser {
    public let id: Int
    public let loginId: String
    public let phoneNumber: String
    public let subscribeEmail: String?
    public let nickname: String
    public let birthYear: String
    public let gender: String
    public let createdAt: String
    public let industryId: Int?
    public let interests: [MypageInterest]

    public init(
        id: Int,
        loginId: String,
        phoneNumber: String,
        subscribeEmail: String?,
        nickname: String,
        birthYear: String,
        gender: String,
        createdAt: String,
        industryId: Int?,
        interests: [MypageInterest]
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
        self.interests = interests
    }

    public func with(nickname: String) -> MypageUser {
        MypageUser(id: id, loginId: loginId, phoneNumber: phoneNumber, subscribeEmail: subscribeEmail, nickname: nickname, birthYear: birthYear, gender: gender, createdAt: createdAt, industryId: industryId, interests: interests)
    }

    public func with(industryId: Int) -> MypageUser {
        MypageUser(id: id, loginId: loginId, phoneNumber: phoneNumber, subscribeEmail: subscribeEmail, nickname: nickname, birthYear: birthYear, gender: gender, createdAt: createdAt, industryId: industryId, interests: interests)
    }

    public func with(interests: [MypageInterest]) -> MypageUser {
        MypageUser(id: id, loginId: loginId, phoneNumber: phoneNumber, subscribeEmail: subscribeEmail, nickname: nickname, birthYear: birthYear, gender: gender, createdAt: createdAt, industryId: industryId, interests: interests)
    }
}
