//
//  SignupResponseDTO.swift
//  Data
//
//  Created by 권민재 on 3/30/25.
//


import Foundation
import Domain


public struct SignupResponseDTO: Decodable {
    public let user: UserDTO
    public let accessToken: String
    
    public func toDomain() -> Domain.SignupResponse {
        return SignupResponse(user: user.toDomain(), accessToken: accessToken)
    }
}

