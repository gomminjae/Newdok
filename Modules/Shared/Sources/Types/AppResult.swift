//
//  AppResult.swift
//  Shared
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation

// MARK: - App-specific Result Type
public typealias AppResult<T> = Result<T, AppError>

// MARK: - App Error Types
public enum AppError: Error, LocalizedError {
    case network(NetworkError)
    case validation(ValidationError)
    case business(BusinessError)
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.localizedDescription
        case .validation(let error):
            return error.localizedDescription
        case .business(let error):
            return error.localizedDescription
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Network Error
public enum NetworkError: Error, LocalizedError {
    case noConnection
    case timeout
    case serverError(Int, String?)
    case unauthorized
    case notFound
    case invalidResponse
    case decodingError(String)
    
    public var errorDescription: String? {
        switch self {
        case .noConnection:
            return "네트워크 연결을 확인해주세요."
        case .timeout:
            return "요청 시간이 초과되었습니다."
        case .serverError(let code, let message):
            return message ?? "서버 오류 (코드: \(code))"
        case .unauthorized:
            return "세션이 만료되었습니다. 다시 로그인해주세요."
        case .notFound:
            return "요청한 리소스를 찾을 수 없습니다."
        case .invalidResponse:
            return "잘못된 응답입니다."
        case .decodingError(let details):
            return "데이터 처리 중 오류가 발생했습니다: \(details)"
        }
    }
}

// MARK: - Validation Error
public enum ValidationError: Error, LocalizedError {
    case emptyField(String)
    case invalidFormat(String)
    case lengthMismatch(String, expected: ClosedRange<Int>)
    case duplicateValue(String)
    case insufficientSelection(String, minimum: Int)
    
    public var errorDescription: String? {
        switch self {
        case .emptyField(let field):
            return "\(field)을(를) 입력해주세요."
        case .invalidFormat(let field):
            return "\(field) 형식이 올바르지 않습니다."
        case .lengthMismatch(let field, let expected):
            return "\(field)은(는) \(expected.lowerBound)~\(expected.upperBound)자 이내로 입력해주세요."
        case .duplicateValue(let field):
            return "이미 사용중인 \(field)입니다."
        case .insufficientSelection(let field, let minimum):
            return "\(field)을(를) 최소 \(minimum)개 이상 선택해주세요."
        }
    }
}

// MARK: - Business Logic Error
public enum BusinessError: Error, LocalizedError {
    case loginFailed
    case signupFailed
    case sessionExpired
    case insufficientPermission
    case dataNotFound
    case operationNotAllowed
    
    public var errorDescription: String? {
        switch self {
        case .loginFailed:
            return "아이디 또는 비밀번호가 올바르지 않습니다."
        case .signupFailed:
            return "회원가입에 실패했습니다."
        case .sessionExpired:
            return "세션이 만료되었습니다. 다시 로그인해주세요."
        case .insufficientPermission:
            return "권한이 부족합니다."
        case .dataNotFound:
            return "데이터를 찾을 수 없습니다."
        case .operationNotAllowed:
            return "허용되지 않은 작업입니다."
        }
    }
}



// MARK: - AppResult Extensions for async/await
public extension AppResult {
    
    /// async 함수를 AppResult로 감싸기
    static func catching<T>(_ work: () async throws -> T) async -> AppResult<T> {
        do {
            let result = try await work()
            return .success(result)
        } catch let error as AppError {
            return .failure(error)
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }
    
    /// 성공 시 특정 액션 실행  
    func onSuccess(_ action: (Success) -> Void) -> AppResult<Success> {
        if case .success(let value) = self {
            action(value)
        }
        return self
    }
    
    /// 실패 시 특정 액션 실행
    func onFailure(_ action: (AppError) -> Void) -> AppResult<Success> {
        if case .failure(let error) = self {
            action(error)
        }
        return self
    }
} 