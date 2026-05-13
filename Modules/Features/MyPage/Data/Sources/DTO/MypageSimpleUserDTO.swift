//
//  MypageSimpleUserDTO.swift
//  MypageData
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation
import MypageDomain

public struct MypageSimpleUserDTO: Decodable, Sendable {
    let id: Int
    let loginId: String
    let phoneNumber: String
    let createdAt: String

    public func toDomain() -> MypageSimpleUser {
        return MypageSimpleUser(
            id: id,
            loginId: loginId,
            phoneNumber: phoneNumber,
            createdAt: createdAt
        )
    }
}
