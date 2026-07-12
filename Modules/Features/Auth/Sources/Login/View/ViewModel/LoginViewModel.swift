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
    ) {
        guard !isLoading else { return }
        isLoading = true

        Task {
            do {
                let idToken = try await kakaoAuthService.fetchIDToken()
                try await authenticate(
                    provider: .kakao,
                    idToken: idToken,
                    onLoggedIn: onLoggedIn,
                    onNeedSignup: onNeedSignup
                )
            } catch {
                isLoading = false
                handle(error)
            }
        }
    }

    /// 애플 로그인: 서비스로 idToken 획득 후 서버 로그인 (카카오와 동일 흐름)
    public func loginWithApple(
        onLoggedIn: @escaping () -> Void,
        onNeedSignup: @escaping (_ signupToken: String, _ suggestedNickname: String?) -> Void
    ) {
        guard !isLoading else { return }
        isLoading = true

        Task {
            do {
                let idToken = try await appleAuthService.fetchIDToken()
                try await authenticate(
                    provider: .apple,
                    idToken: idToken,
                    onLoggedIn: onLoggedIn,
                    onNeedSignup: onNeedSignup
                )
            } catch {
                isLoading = false
                handle(error)
            }
        }
    }

    private func authenticate(
        provider: SocialProvider,
        idToken: String,
        onLoggedIn: @escaping () -> Void,
        onNeedSignup: @escaping (_ signupToken: String, _ suggestedNickname: String?) -> Void
    ) async throws {
        defer { isLoading = false }
        let result = try await loginUseCase.execute(provider: provider, idToken: idToken)
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
