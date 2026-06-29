import Foundation
import AuthDomain
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon

@MainActor
public struct KakaoAuthService: KakaoAuthServiceProtocol {
    public init() {}

    public func fetchIDToken() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let completion: (OAuthToken?, Error?) -> Void = { token, error in
                if let error {
                    continuation.resume(throwing: Self.map(error))
                } else if let idToken = token?.idToken {
                    continuation.resume(returning: idToken)
                } else {
                    continuation.resume(throwing: LoginError.missingIDToken)
                }
            }

            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(completion: completion)
            } else {
                UserApi.shared.loginWithKakaoAccount(completion: completion)
            }
        }
    }

    private static func map(_ error: Error) -> LoginError {
        if let sdkError = error as? SdkError,
           case .ClientFailed(let reason, _) = sdkError,
           reason == .Cancelled {
            return .cancelled
        }
        return .networkError(error)
    }
}
