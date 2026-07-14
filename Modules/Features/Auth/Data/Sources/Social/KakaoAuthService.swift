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
                    #if DEBUG
                    Self.logPayload(idToken)
                    #endif
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

    #if DEBUG
    private static func logPayload(_ idToken: String) {
        let segments = idToken.split(separator: ".")
        guard segments.count >= 2 else { return }
        var base64 = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
        guard let data = Data(base64Encoded: base64),
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        print("[KakaoAuth] idToken aud: \(payload["aud"] ?? "nil"), iss: \(payload["iss"] ?? "nil"), sub: \(payload["sub"] ?? "nil")")
    }
    #endif

    private static func map(_ error: Error) -> LoginError {
        if let sdkError = error as? SdkError,
           case .ClientFailed(let reason, _) = sdkError,
           reason == .Cancelled {
            return .cancelled
        }
        return .networkError(error)
    }
}
