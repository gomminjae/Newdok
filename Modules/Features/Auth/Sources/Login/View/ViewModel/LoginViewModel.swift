//
//  LoginViewModel.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//
import SwiftUI
import AuthDomain
import Shared
import Observation
import AuthenticationServices

@Observable
@MainActor
public final class LoginViewModel: ErrorHandling {
    private let loginUseCase: LoginUseCase
    private let kakaoAuthService: KakaoAuthServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    private let appState: AppState

    public var isLoading: Bool
    public var currentError: AppError?

    public init(
        loginUseCase: LoginUseCase,
        kakaoAuthService: KakaoAuthServiceProtocol,
        tokenStorage: TokenStorageProtocol,
        appState: AppState
    ) {
        self.loginUseCase = loginUseCase
        self.kakaoAuthService = kakaoAuthService
        self.tokenStorage = tokenStorage
        self.appState = appState
        self.isLoading = false
    }

    /// 카카오 로그인: SDK로 idToken 획득 후 서버 로그인
    public func loginWithKakao(onSuccess: @escaping () -> Void) {
        guard !isLoading else { return }
        isLoading = true

        Task {
            do {
                let idToken = try await kakaoAuthService.fetchIDToken()
                try await authenticate(provider: .kakao, idToken: idToken, onSuccess: onSuccess)
            } catch {
                isLoading = false
                handle(error)
            }
        }
    }

    /// 애플 로그인: SignInWithAppleButton 콜백 결과 처리
    public func handleAppleResult(
        _ result: Result<ASAuthorization, Error>,
        onSuccess: @escaping () -> Void
    ) {
        guard !isLoading else { return }

        switch result {
        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8)
            else {
                handle(LoginError.missingIDToken)
                return
            }
            isLoading = true
            Task {
                do {
                    try await authenticate(provider: .apple, idToken: idToken, onSuccess: onSuccess)
                } catch {
                    isLoading = false
                    handle(error)
                }
            }
        case .failure(let error):
            if (error as? ASAuthorizationError)?.code == .canceled { return }
            handle(LoginError.networkError(error))
        }
    }

    private func authenticate(
        provider: SocialProvider,
        idToken: String,
        onSuccess: @escaping () -> Void
    ) async throws {
        defer { isLoading = false }
        _ = try await loginUseCase.execute(provider: provider, idToken: idToken)
        currentError = nil
        appState.login()
        onSuccess()
    }

    private func handle(_ error: Error) {
        switch error {
        case LoginError.cancelled:
            // 사용자가 취소 — 조용히 무시
            break
        case LoginError.missingIDToken:
            currentError = .userMessage(LoginError.missingIDToken.localizedDescription)
        case LoginError.networkError(let underlying):
            handleError(underlying, feature: "login", operation: "socialLogin")
        default:
            handleError(error, feature: "login", operation: "socialLogin")
        }
    }

    public func loginAsGuest() {
        tokenStorage.clear()
        appState.logout()
    }
}
