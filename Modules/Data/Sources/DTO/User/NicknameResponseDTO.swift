//
//  NicknameResponseDTO.swift
//  Data
//
//  Created by 권민재 on 3/30/25.
//

import Foundation
import Domain

public struct NicknameResponseDTO: Decodable {
    let id: Int
    let loginId: String
    let nickname: Bool
    
    public func toDomain() -> NicknameResponse {
        return NicknameResponse(id: id, loginId: loginId, nickname: nickname)
    }
    
    
    
}
