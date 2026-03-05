//
//  ErrorMapper.swift
//  Network
//
//  Created by 권민재 on 3/30/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import Foundation
import Moya
import Alamofire

private struct ServerErrorBody: Decodable {
    let message: String?
    let error: String?

    var displayMessage: String? {
        message ?? error
    }
}

enum ErrorMapper {
    static func map(response: Response) -> NetworkError {
        if let body = try? JSONDecoder().decode(ServerErrorBody.self, from: response.data),
           let message = body.displayMessage {
            return .serverError(statusCode: response.statusCode, message: message)
        }
        let message = try? response.mapString()
        return .serverError(statusCode: response.statusCode, message: message)
    }

    static func map(moyaError: MoyaError) -> NetworkError {
        switch moyaError {
        case .underlying(let error, _):
            let urlError: URLError? = {
                if let ue = error as? URLError {
                    return ue
                }
                if let afError = error as? AFError,
                   case .sessionTaskFailed(let underlying) = afError,
                   let ue = underlying as? URLError {
                    return ue
                }
                return nil
            }()

            if let urlError {
                switch urlError.code {
                case .notConnectedToInternet:
                    return .noInternet
                case .timedOut:
                    return .timeout
                case .cancelled:
                    return .cancelled
                case .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
                    return .serverError(statusCode: 0, message: urlError.localizedDescription)
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
