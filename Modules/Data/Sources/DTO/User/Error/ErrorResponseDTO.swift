//
//  ErrorResponseDTO.swift
//  Data
//
//  Created by 권민재 on 3/27/25.
//

import Foundation
import Domain

public struct ErrorResponseDTO: Decodable, Error {
    public let statusCode: Int
    public let message: String
    public let error: String
    
    public func toDomain() -> ErrorResponse {
        return ErrorResponse(statusCode: statusCode, message: message, error: error)
    }
    
}
