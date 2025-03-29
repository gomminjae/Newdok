//
//  NetworkError.swift
//  Network
//
//  Created by 권민재 on 3/28/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import Foundation
import Moya

enum NetworkError: Error, LocalizedError {
    
    case decodeError(underlying: Error)
    case serverError(statusCode: Int, message: String?)
    case underlying(Error)
    case unknown
    case timeout
    case noInternet
    case cancelled

    var errorDescription: String? {
        switch self {
        case .decodeError(let error):
            return "디코딩 실패: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "서버 오류 (\(code)): \(message ?? "알 수 없는 오류")"
        case .underlying(let error):
            return error.localizedDescription
        case .timeout:
            return "요청 시간이 초과되었습니다."
        case .noInternet:
            return "인터넷 연결이 없습니다."
        case .cancelled:
            return "요청이 취소되었습니다."
        case .unknown:
            return "알 수 없는 네트워크 오류가 발생했습니다."
        }
    }
}
