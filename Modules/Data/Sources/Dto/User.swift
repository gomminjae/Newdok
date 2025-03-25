//
//  Untitled.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//

import Foundation

import Foundation

struct User: Codable {
    let id: Int
    let loginId: String
    let password: String
    let phoneNumber: String
    let subscribeEmail: String
    let subscribePassword: String
    let nickname: String
    let birthYear: String
    let gender: String
    let emailIndex: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case loginId
        case password
        case phoneNumber
        case subscribeEmail
        case subscribePassword
        case nickname
        case birthYear
        case gender
        case emailIndex
        case createdAt
    }
}

// JSON 디코딩을 위한 날짜 포맷 설정
extension JSONDecoder {
    static var iso8601Decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            guard let date = formatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
            }
            return date
        }
        return decoder
    }
}
