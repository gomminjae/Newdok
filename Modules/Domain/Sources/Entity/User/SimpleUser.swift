//
//  SimpleUser.swift
//  Domain
//
//  Created by 권민재 on 3/27/25.
//
import Foundation

public struct SimpleUser: Identifiable {
    public let id: Int
    public let loginId: String
    public let phoneNumber: String
    public let createdAt: String
    
    
    
    public var maskedLoginId: String {
        let prefix = loginId.prefix(4)
        
        // 남은 글자 수만큼 * 생성
        let starCount = max(0, loginId.count - 4)
        let stars = String(repeating: "*", count: starCount)
        
        return "\(prefix)\(stars)"
    }
    
    public var formattedCreatedAt: String {
            // 1) ISO8601 → Date
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            guard let date = isoFormatter.date(from: createdAt) else {
                return createdAt
            }

            // 2) Date → 원하는 문자열 포맷
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "ko_KR")
            displayFormatter.dateFormat = "yyyy.MM.dd"
            return "\(displayFormatter.string(from: date)) 가입"
        }
    
    public init(
        id: Int,
        loginId: String,
        phoneNumber: String,
        createdAt: String
    ) {
        self.id = id
        self.loginId = loginId
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
    }
}
