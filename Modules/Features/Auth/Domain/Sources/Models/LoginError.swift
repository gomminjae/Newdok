import Foundation

public enum LoginError: Error, LocalizedError {
    /// 사용자가 소셜 로그인 동의/인증을 취소함
    case cancelled
    /// 소셜 SDK에서 idToken을 받지 못함
    case missingIDToken
    /// Apple 인증 결과에서 authorizationCode를 받지 못함
    case missingAuthorizationCode
    case networkError(Error)
    case tokenPersistenceFailed

    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "로그인이 취소되었습니다"
        case .missingIDToken:
            return "소셜 로그인 정보를 가져오지 못했습니다"
        case .missingAuthorizationCode:
            return "Apple 로그인 정보를 가져오지 못했습니다. 다시 시도해주세요"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .tokenPersistenceFailed:
            return "로그인 정보를 저장하지 못했습니다. 다시 시도해주세요"
        }
    }
}
