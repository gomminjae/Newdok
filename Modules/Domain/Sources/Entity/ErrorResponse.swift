//
//  ErrorResponse.swift
//  Domain
//
//  Created by 권민재 on 3/27/25.
//

import Foundation


public struct ErrorResponse {
    
    public let statusCode: Int
    public let message: String
    public let error: String
    
    public init(statusCode: Int, message: String, error: String) {
        self.statusCode = statusCode
        self.message = message
        self.error = error
    }
    
}
