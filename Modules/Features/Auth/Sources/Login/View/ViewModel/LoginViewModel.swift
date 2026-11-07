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

@Observable
@MainActor
public final class LoginViewModel: ErrorHandling {
    private let loginUseCase: LoginUseCase
    private let kakaoAuthService: KakaoAuthServiceProtocol
    private let appleAuthService: AppleAuthServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    private let appState: AppState

    public var isLoading: Bool
    public var currentError: AppError?

    public init(
        loginUseCase: LoginUseCase,
        kakaoAuthService: KakaoAuthServiceProtocol,
        appleAuthService: AppleAuthServiceProtocol,
        tokenStorage: TokenStorageProtocol,
        appState: AppState
    ) {
        self.loginUseCase = loginUseCase
        self.kakaoAuthService = kakaoAuthService
        self.appleAuthService = appleAuthService
        self.tokenStorage = tokenStorage
        self.appState = appState
        self.isLoading = false
    }

    /// 카카오 로그인: SDK로 idToken 획득 후 서버 로그인
    public func loginWithKakao(
        onLoggedIn: @escaping () -> Void,
        onNeedSignup: @escaping (_ signupToken: String, _ suggestedNickname: String?) -> Void
    ) async {
        guard !isLoading, !Task.isCancelled else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let idToken = try await kakaoAuthService.fetchIDToken()
            try Task.checkCancellation()
            try await authenticate(
                with: .kakao(idToken: idToken),
                onLoggedIn: onLoggedIn,
                onNeedSignup: onNeedSignup
            )
        } catch {
            handle(error)
        }
    }

    /// 애플 로그인: 서비스로 idToken 획득 후 서버 로그인 (카카오와 동일 흐름)
    public func loginWithApple(
        onLoggedIn: @escaping () -> Void,
        onNeedSignup: @escaping (_ signupToken: String, _ suggestedNickname: String?) -> Void
    ) async {
        guard !isLoading, !Task.isCancelled else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let credential = try await appleAuthService.fetchCredential()
            try Task.checkCancellation()
            try await authenticate(
                with: .apple(
                    idToken: credential.idToken,
                    authorizationCode: credential.authorizationCode
                ),
                onLoggedIn: onLoggedIn,
                onNeedSignup: onNeedSignup
            )
        } catch {
            handle(error)
        }
    }

    private func authenticate(
        with credential: SocialLoginCredential,
        onLoggedIn: @escaping () -> Void,
        onNeedSignup: @escaping (_ signupToken: String, _ suggestedNickname: String?) -> Void
    ) async throws {
        let result = try await loginUseCase.execute(credential: credential)
        try Task.checkCancellation()
        currentError = nil

        switch result {
        case .registered:
            appState.login()
            onLoggedIn()
        case let .newUser(signupToken, suggestedNickname):
            onNeedSignup(signupToken, suggestedNickname)
        }
    }

    private func handle(_ error: Error) {
        guard !Task.isCancelled, !(error is CancellationError) else { return }
        switch error {
        case LoginError.cancelled:
            // 사용자가 취소 — 조용히 무시
            break
        case LoginError.missingIDToken:
            currentError = .userMessage(LoginError.missingIDToken.localizedDescription)
        case LoginError.missingAuthorizationCode:
            currentError = .userMessage(LoginError.missingAuthorizationCode.localizedDescription)
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
