//
//  MypageUserDTO.swift
//  MypageData
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation
import MypageDomain

public struct MypageInterestDTO: Decodable {
    let id: Int
    let name: String

    public func toDomain() -> MypageInterest {
        return MypageInterest(id: id, name: name)
    }
}

public struct MypageLoginInterestDTO: Decodable {
    let userId: Int
    let interestId: Int
    let createdAt: String

    public func toDomain() -> MypageInterest {
        return MypageInterest(
            id: interestId,
            name: "" // 로그인 응답에는 name이 없으니까 빈 값
        )
    }
}

public struct MypageUserDTO: Decodable {
    let id: Int
    let loginId: String
    let phoneNumber: String
    let subscribeEmail: String?
    let nickname: String
    let birthYear: String
    let gender: String
    let createdAt: String
    let industryId: Int?
    let interests: [MypageLoginInterestDTO]?

    public func toDomain() -> MypageUser {
        return MypageUser(
            id: id,
            loginId: loginId,
            phoneNumber: phoneNumber,
            subscribeEmail: subscribeEmail,
            nickname: nickname,
            birthYear: birthYear,
            gender: gender,
            createdAt: createdAt,
            industryId: industryId ?? 0,
            interests: interests?.map { $0.toDomain() } ?? []
        )
    }
}
