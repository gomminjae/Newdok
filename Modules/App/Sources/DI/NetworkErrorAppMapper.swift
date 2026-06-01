import NetworkKit
import Shared

struct NetworkErrorAppMapper: AppErrorMapping {
    func map(_ error: Error) -> AppError? {
        guard let networkError = error as? NetworkError else { return nil }
        switch networkError {
        case .noInternet:
            return .noInternet
        case .timeout:
            return .timeout
        case .cancelled:
            return .silent
        case .serverError(let statusCode, _):
            if statusCode == 401 {
                return .unauthorized
            }
            if (400..<500).contains(statusCode) {
                return .silent
            }
            return .serverError
        case .decodeError, .underlying, .unknown:
            return .userMessage("일시적인 오류가 발생했습니다")
        }
    }
}
