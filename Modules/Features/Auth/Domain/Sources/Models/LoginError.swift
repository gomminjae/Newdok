import Shared

public enum LoginError: Error {
    case invalidPassword
    case accountNotFound
    case networkError(Error)
}

extension LoginError: AppErrorConvertible {
    public func toAppError() -> AppError {
        switch self {
        case .invalidPassword:
            return .userMessage("비밀번호가 일치하지 않습니다")
        case .accountNotFound:
            return .userMessage("등록되지 않은 계정이거나, 아이디를 다시 확인해주세요")
        case .networkError(let underlying):
            if let convertible = underlying as? AppErrorConvertible {
                return convertible.toAppError()
            }
            return .userMessage("네트워크 오류가 발생했습니다")
        }
    }
}
