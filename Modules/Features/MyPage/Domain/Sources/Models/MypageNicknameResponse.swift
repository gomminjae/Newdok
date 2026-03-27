//
//  MypageNicknameResponse.swift
//  MypageDomain
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation

public struct MypageNicknameResponse {
    public let id: Int
    public let loginId: String
    public let nickname: String

    public init(id: Int, loginId: String, nickname: String) {
        self.id = id
        self.loginId = loginId
        self.nickname = nickname
    }
}
