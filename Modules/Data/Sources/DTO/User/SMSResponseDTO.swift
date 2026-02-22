//
//  SMSResponseDTO.swift
//  Data
//
//  Created by 권민재 on 4/6/25.
//

import Domain
import Foundation

public struct SMSResponseDTO: Decodable {
    let code: Int
    
    public func toDomain() -> SMSResponse {
        return SMSResponse(code: code)
    }
}
