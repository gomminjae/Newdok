//
//  MypageNicknameResponseDTO.swift
//  MypageData
//
//  Created by 권민재 on 3/28/26.
//  Copyright © 2026 Newdok. All rights reserved.
//

import Foundation
import MypageDomain

public struct MypageNicknameResponseDTO: Decodable, Sendable {
    let id: Int
    let nickname: String

    public func toDomain() -> MypageNicknameResponse {
        return MypageNicknameResponse(id: id, nickname: nickname)
    }
}
