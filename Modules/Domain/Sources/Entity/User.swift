//
//  User.swift
//  Domain
//
//  Created by 권민재 on 3/27/25.
//
import Foundation


// MARK: - User
public struct User {
    public let id: Int
    public let loginId: String
    public let phoneNumber: String
    public let email: String
    public let nickname: String
    public let birthYear: Int
    public let gender: Gender
    public let createdAt: Date
    public let industryId: Int
    public let interests: [Interest]

    public init(
        id: Int,
        loginId: String,
        phoneNumber: String,
        email: String,
        nickname: String,
        birthYear: Int,
        gender: Gender,
        createdAt: Date,
        industryId: Int,
        interests: [Interest]
    ) {
        self.id = id
        self.loginId = loginId
        self.phoneNumber = phoneNumber
        self.email = email
        self.nickname = nickname
        self.birthYear = birthYear
        self.gender = gender
        self.createdAt = createdAt
        self.industryId = industryId
        self.interests = interests
    }
}
