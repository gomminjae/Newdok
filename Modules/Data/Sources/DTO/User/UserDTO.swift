//
//  Untitled.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//

import Foundation
import Domain


public struct InterestDTO: Decodable {
    public let interestId: Int
    public let name: String

    public func toDomain() -> Domain.Interest {
        return Domain.Interest(id: interestId, name: name)
    }
}


public struct UserDTO: Decodable {
    public let id: Int
    public let loginId: String
    public let phoneNumber: String
    public let subscribeEmail: String
    public let nickname: String
    public let birthYear: String
    public let gender: String
    public let createdAt: String
    public let industryId: Int
    public let interests: [InterestDTO]

    public func toDomain() -> User {

        return User(
            id: id,
            loginId: loginId,
            phoneNumber: phoneNumber,
            email: subscribeEmail,
            nickname: nickname,
            birthYear: birthYear,
            gender: gender,
            createdAt: createdAt,
            industryId: industryId,
            interests: interests.map { $0.toDomain() }
            
        )
    }
}
