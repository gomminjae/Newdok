//
//  ErrorMapper.swift
//  Network
//
//  Created by 권민재 on 3/30/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import Foundation
import Moya

enum ErrorMapper {
    static func map(response: Response) -> NetworkError {
        let message = try? response.mapString()
        return .serverError(statusCode: response.statusCode, message: message)
    }

    static func map(moyaError: MoyaError) -> NetworkError {
        switch moyaError {
        case .underlying(let error, _):
            if let urlError = error as? URLError {
                switch urlError.code {
                case .notConnectedToInternet:
                    return .noInternet
                case .timedOut:
                    return .timeout
                case .cancelled:
                    return .cancelled
                default:
                    return .underlying(urlError)
                }
            }
            return .underlying(error)

        case .statusCode(let response):
            return map(response: response)

        case .objectMapping, .encodableMapping, .parameterEncoding, .jsonMapping:
            return .decodeError(underlying: moyaError)

        default:
            return .unknown
        }
    }
}
