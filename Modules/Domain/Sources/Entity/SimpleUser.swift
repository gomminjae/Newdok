//
//  SimpleUser.swift
//  Domain
//
//  Created by 권민재 on 3/27/25.
//
import Foundation

public struct SimpleUser {
    public let id: Int
    public let loginId: String
    public let phoneNumber: String
    public let createdAt: Date
    
    public init(
        id: Int,
        loginId: String,
        phoneNumber: String,
        createdAt: Date
    ) {
        self.id = id
        self.loginId = loginId
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
    }
}
