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
    
    public var maskedLoginId: String {
        let prefix = loginId.prefix(4)
        return "\(prefix)****"
    }
    
    public var formattedCreatedAt: String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.string(from: createdAt) + " 가입"
        }
    
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
