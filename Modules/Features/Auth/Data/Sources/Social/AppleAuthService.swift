import Foundation
import UIKit
import AuthDomain
import AuthenticationServices

@MainActor
public struct AppleAuthService: AppleAuthServiceProtocol {
    public init() {}

    public func fetchCredential() async throws -> AppleAuthCredential {
        let manager = AppleSignInManager()
        let credential: AppleAuthCredential = try await withTaskCancellationHandler {
            try Task.checkCancellation()
            return try await withCheckedThrowingContinuation { continuation in
                // completion이 manager를 보유하고 finish가 이를 먼저 해제한다.
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
                        continuation.resume(throwing: error is CancellationError ? error : Self.map(error))
                    }
                }
            }
        } onCancel: {
            Task { @MainActor in manager.cancel() }
        }
        try Task.checkCancellation()
        return credential
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
@MainActor
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
        let completion = self.completion
        self.completion = nil
        controller = nil
        completion?(result)
    }

    func cancel() {
        let controller = self.controller
        finish(.failure(CancellationError()))
        controller?.cancel()
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
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow) ?? ASPresentationAnchor()
    }
}
