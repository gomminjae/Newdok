//
//  SimpleUserDTO.swift
//  Data
//
//  Created by 권민재 on 3/27/25.
//
import Foundation
import Domain


public struct SimpleUserDTO: Decodable {
    public let id: Int
    public let loginId: String
    public let phoneNumber: String
    public let createdAt: String
    
    public func toDomain() -> Domain.SimpleUser {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: createdAt) ?? Date()
        
        return Domain.SimpleUser(
            id: id,
            loginId: loginId,
            phoneNumber: phoneNumber,
            createdAt: date
        )
    }
}
