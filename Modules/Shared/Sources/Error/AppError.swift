//
//  AppError.swift
//  Shared
//
//  Created by 권민재 on 2/28/26.
//

import Foundation

public enum AppError: Error, Equatable {
    case noInternet
    case timeout
    case serverMessage(String)
    case unauthorized
    case userMessage(String)
    case serverError
    case silent

    public var userFacingMessage: String {
        switch self {
        case .noInternet:
            return "인터넷 연결을 확인해주세요"
        case .timeout:
            return "요청 시간이 초과되었습니다. 다시 시도해주세요"
        case .serverMessage(let message):
            return message
        case .unauthorized:
            return "로그인이 필요합니다"
        case .userMessage(let message):
            return message
        case .serverError:
            return "일시적인 오류가 발생했습니다"
        case .silent:
            return ""
        }
    }

    public var shouldShowToast: Bool {
        switch self {
        case .silent, .serverError:
            return false
        default:
            return true
        }
    }

    public var requiresFullScreenError: Bool {
        switch self {
        case .noInternet, .unauthorized, .serverError:
            return true
        default:
            return false
        }
    }
}

public protocol AppErrorConvertible {
    func toAppError() -> AppError
}
