//
//  NicknameResponse.swift
//  Domain
//
//  Created by 권민재 on 3/30/25.
//

import Foundation

public struct NicknameResponse {
    let id: Int
    let loginId: String
    let nickname: String
    
    public init(id: Int, loginId: String, nickname: String) {
        self.id = id
        self.loginId = loginId
        self.nickname = nickname
    }
    
    
}
