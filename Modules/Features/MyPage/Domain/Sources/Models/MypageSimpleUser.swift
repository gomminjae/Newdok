//
//  MypageSimpleUser.swift
//  MypageDomain
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation
import FoundationKit

public struct MypageSimpleUser: Identifiable {
    public let id: Int
    public let loginId: String
    public let phoneNumber: String
    public let createdAt: String

    public var maskedLoginId: String {
        let prefix = loginId.prefix(4)
        let starCount = max(0, loginId.count - 4)
        let stars = String(repeating: "*", count: starCount)
        return "\(prefix)\(stars)"
    }

    public var formattedCreatedAt: String {
        guard let date = createdAt.newdokISODate else {
            return createdAt
        }
        return "\(date.newdokJoinDateText) 가입"
    }

    public init(id: Int, loginId: String, phoneNumber: String, createdAt: String) {
        self.id = id
        self.loginId = loginId
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
    }
}
