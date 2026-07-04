import Foundation

public enum LoginError: Error, LocalizedError {
    case invalidPassword
    case accountNotFound
    case networkError(Error)
    case tokenPersistenceFailed

    public var errorDescription: String? {
        switch self {
        case .invalidPassword:
            return "비밀번호가 일치하지 않습니다"
        case .accountNotFound:
            return "등록되지 않은 계정이거나, 아이디를 다시 확인해주세요"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .tokenPersistenceFailed:
            return "로그인 정보를 저장하지 못했습니다. 다시 시도해주세요"
        }
    }
}
