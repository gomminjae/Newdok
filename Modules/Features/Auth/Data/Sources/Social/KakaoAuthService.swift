import Foundation
import AuthDomain
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon

@MainActor
public struct KakaoAuthService: KakaoAuthServiceProtocol {
    typealias LoginCompletion = @MainActor @Sendable (Result<String, Error>) -> Void
    typealias StartLogin = @MainActor @Sendable (@escaping LoginCompletion) -> Void

    private let startLogin: StartLogin

    public init() {
        startLogin = Self.loginWithSDK
    }

    init(startLogin: @escaping StartLogin) {
        self.startLogin = startLogin
    }

    public func fetchIDToken() async throws -> String {
        let attempt = KakaoLoginAttempt()
        let idToken: String = try await withTaskCancellationHandler {
            try Task.checkCancellation()
            return try await withCheckedThrowingContinuation { continuation in
                attempt.continuation = continuation
                guard !Task.isCancelled else {
                    attempt.finish(.failure(CancellationError()))
                    return
                }
                startLogin { result in
                    attempt.finish(result)
                }
            }
        } onCancel: {
            Task { @MainActor in
                attempt.finish(.failure(CancellationError()))
            }
        }
        try Task.checkCancellation()
        return idToken
    }

    private static func loginWithSDK(completion: @escaping LoginCompletion) {
        let callback: @Sendable (OAuthToken?, Error?) -> Void = { token, error in
            let result: Result<String, Error>
            if let error {
                result = .failure(Self.map(error))
            } else if let idToken = token?.idToken, !idToken.isEmpty {
                result = .success(idToken)
            } else {
                result = .failure(LoginError.missingIDToken)
            }

            // Only the normalized String/Error crosses the SDK callback boundary.
            Task { @MainActor in completion(result) }
        }

        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk(completion: callback)
        } else {
            UserApi.shared.loginWithKakaoAccount(completion: callback)
        }
    }

    private nonisolated static func map(_ error: Error) -> LoginError {
        if let sdkError = error as? SdkError,
           case .ClientFailed(let reason, _) = sdkError,
           reason == .Cancelled {
            return .cancelled
        }
        return .networkError(error)
    }
}

@MainActor
private final class KakaoLoginAttempt {
    var continuation: CheckedContinuation<String, Error>?

    func finish(_ result: Result<String, Error>) {
        guard let continuation else { return }
        // Consume before resuming: duplicate callbacks and cancellation are serialized
        // on MainActor and cannot complete the same login attempt twice.
        self.continuation = nil
        continuation.resume(with: result)
    }
}
