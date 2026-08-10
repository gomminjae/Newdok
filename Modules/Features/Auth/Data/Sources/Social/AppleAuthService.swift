import Foundation
import UIKit
import AuthDomain
import AuthenticationServices

@MainActor
public struct AppleAuthService: AppleAuthServiceProtocol {
    public init() {}

    public func fetchCredential() async throws -> AppleAuthCredential {
        try await withCheckedThrowingContinuation { continuation in
            // manager를 completion 클로저에서 강하게 잡아 콜백 시점까지 생존시킴
            let manager = AppleSignInManager()
            manager.request { result in
                _ = manager
                switch result {
                case .success(let authorization):
                    do {
                        continuation.resume(returning: try Self.credential(from: authorization))
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: Self.map(error))
                }
            }
        }
    }

    private static func credential(from authorization: ASAuthorization) throws -> AppleAuthCredential {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else { throw LoginError.missingIDToken }

        guard
            let codeData = credential.authorizationCode,
            let authorizationCode = String(data: codeData, encoding: .utf8)
        else { throw LoginError.missingAuthorizationCode }

        return AppleAuthCredential(
            idToken: idToken,
            authorizationCode: authorizationCode
        )
    }

    private static func map(_ error: Error) -> LoginError {
        if (error as? ASAuthorizationError)?.code == .canceled {
            return .cancelled
        }
        return .networkError(error)
    }
}

/// ASAuthorizationController를 async로 감싸기 위한 델리게이트 래퍼
private final class AppleSignInManager: NSObject {
    private var completion: ((Result<ASAuthorization, Error>) -> Void)?
    private var controller: ASAuthorizationController?

    func request(_ completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.completion = completion
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        self.controller = controller
        controller.performRequests()
    }

    private func finish(_ result: Result<ASAuthorization, Error>) {
        completion?(result)
        completion = nil
        controller = nil
    }
}

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        finish(.success(authorization))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        finish(.failure(error))
    }
}

extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // ponytail: 델리게이트는 메인 스레드 콜백 — assumeIsolated로 keyWindow 조회
        MainActor.assumeIsolated {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow) ?? ASPresentationAnchor()
        }
    }
}
