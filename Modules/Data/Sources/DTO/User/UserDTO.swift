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

    public func toDomain() -> Domain.Interest {
        return Domain.Interest(interestId: interestId)
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

    public func toDomain() -> User? {
        guard
            let gender = Gender(rawValue: gender),
            let birthYearInt = Int(birthYear),
            let createdDate = ISO8601DateFormatter().date(from: createdAt)
        else {
            return nil
        }

        return User(
            id: id,
            loginId: loginId,
            phoneNumber: phoneNumber,
            email: subscribeEmail,
            nickname: nickname,
            birthYear: birthYearInt,
            gender: gender,
            createdAt: createdDate,
            industryId: industryId,
            interests: interests.map { $0.toDomain() }
            
        )
    }
}
