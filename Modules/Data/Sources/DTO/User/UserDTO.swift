//
//  Untitled.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//

import Foundation
import Domain


public struct InterestDTO: Decodable {
        let userId: Int
        let interestId: Int
        let createdAt: String

    public func toDomain() -> Domain.Interest {
        return Interest(userId: userId, interestId: interestId, createdAt: createdAt)
    }
}


public struct UserDTO: Decodable {
        let id: Int
        let loginId: String
        let phoneNumber: String
        let subscribeEmail: String
        let nickname: String
        let birthYear: String
        let gender: String
        let createdAt: String
        let industryId: Int
        let interests: [InterestDTO]

    public func toDomain() -> User {

        return User(
            id: id,
            loginId: loginId,
            phoneNumber: phoneNumber,
            subscribeEmail: subscribeEmail,
            nickname: nickname,
            birthYear: birthYear,
            gender: gender,
            createdAt: createdAt,
            industryId: industryId,
            interests: interests.map { $0.toDomain() }
        )
    }
}
