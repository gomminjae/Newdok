//
//  Untitled.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//

import Foundation
import Domain


public struct InterestDTO: Decodable {
        let id: Int
        let name: String
       

    public func toDomain() -> Domain.Interest {
        return Interest(id: id, name: name)
    }
}

public struct LoginInterestDTO: Decodable {
    let userId: Int
    let interestId: Int
    let createdAt: String

    public func toDomain() -> Domain.Interest {
        return Interest(
            id: interestId,
            name: "" // 로그인 응답에는 name이 없으니까 빈 값
        )
    }
}


public struct UserDTO: Decodable {
        let id: Int
        let loginId: String
        let phoneNumber: String
        let subscribeEmail: String?
        let nickname: String
        let birthYear: String
        let gender: String
        let createdAt: String
        let industryId: Int?
        let interests: [LoginInterestDTO]?

    public func toDomain() -> User {

        return User(
            id: id,
            loginId: loginId,
            phoneNumber: phoneNumber,
            subscribeEmail: subscribeEmail,  // 옵셔널 그대로 전달
            nickname: nickname,
            birthYear: birthYear,
            gender: gender,
            createdAt: createdAt,
            industryId: industryId ?? 0,
            interests: interests?.map { $0.toDomain() } ?? []  // nil이면 빈 배열로 처리
        )
    }
}
