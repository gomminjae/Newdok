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
    public let context: AuthAnalyticsContext
    public let analytics: AnalyticsClient

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
        appState: AppState,
        context: AuthAnalyticsContext = AuthAnalyticsContext(),
        analytics: AnalyticsClient = .disabled
    ) {
        self.context = context
        self.analytics = analytics
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
        let attempt = context.beginAttempt(method: .kakao)
        analytics.record(.authAttemptStarted(flowID: context.flowID, attemptID: attempt, method: .kakao), from: .login)
        isLoading = true
        defer { isLoading = false }

        do {
            let idToken = try await kakaoAuthService.fetchIDToken()
            try Task.checkCancellation()
            try await authenticate(
                attempt: attempt,
                method: .kakao,
                with: .kakao(idToken: idToken),
                onLoggedIn: onLoggedIn,
                onNeedSignup: onNeedSignup
            )
        } catch {
            guard context.isCurrent(attempt) else { return }
            if !Task.isCancelled, !(error is CancellationError) {
                let outcome: AnalyticsAuthOutcome
                if case LoginError.cancelled = error { outcome = .cancelled } else { outcome = .failed(failureCategory(error)) }
                analytics.record(.authAttemptFinished(flowID: context.flowID, attemptID: attempt, method: .kakao, outcome: outcome), from: .login)
            }
            context.finishAttempt(attempt)
            handle(error)
        }
    }

    /// 애플 로그인: 서비스로 idToken 획득 후 서버 로그인 (카카오와 동일 흐름)
    public func loginWithApple(
        onLoggedIn: @escaping () -> Void,
        onNeedSignup: @escaping (_ signupToken: String, _ suggestedNickname: String?) -> Void
    ) async {
        guard !isLoading, !Task.isCancelled else { return }
        let attempt = context.beginAttempt(method: .apple)
        analytics.record(.authAttemptStarted(flowID: context.flowID, attemptID: attempt, method: .apple), from: .login)
        isLoading = true
        defer { isLoading = false }

        do {
            let credential = try await appleAuthService.fetchCredential()
            try Task.checkCancellation()
            try await authenticate(
                attempt: attempt,
                method: .apple,
                with: .apple(
                    idToken: credential.idToken,
                    authorizationCode: credential.authorizationCode
                ),
                onLoggedIn: onLoggedIn,
                onNeedSignup: onNeedSignup
            )
        } catch {
            guard context.isCurrent(attempt) else { return }
            if !Task.isCancelled, !(error is CancellationError) {
                let outcome: AnalyticsAuthOutcome
                if case LoginError.cancelled = error { outcome = .cancelled } else { outcome = .failed(failureCategory(error)) }
                analytics.record(.authAttemptFinished(flowID: context.flowID, attemptID: attempt, method: .apple, outcome: outcome), from: .login)
            }
            context.finishAttempt(attempt)
            handle(error)
        }
    }

    private func authenticate(
        attempt: UUID,
        method: AnalyticsAuthMethod,
        with credential: SocialLoginCredential,
        onLoggedIn: @escaping () -> Void,
        onNeedSignup: @escaping (_ signupToken: String, _ suggestedNickname: String?) -> Void
    ) async throws {
        guard context.isCurrent(attempt) else { return }
        let result = try await loginUseCase.execute(credential: credential)
        try Task.checkCancellation()
        guard context.isCurrent(attempt) else { return }
        defer { context.finishAttempt(attempt) }
        currentError = nil

        switch result {
        case .registered:
            appState.login()
            analytics.record(.login(flowID: context.flowID, attemptID: attempt, method: method), from: .login)
            onLoggedIn()
        case let .newUser(signupToken, suggestedNickname):
            analytics.record(.authAttemptFinished(flowID: context.flowID, attemptID: attempt, method: method, outcome: .signupRequired), from: .login)
            onNeedSignup(signupToken, suggestedNickname)
        }
    }

    private func failureCategory(_ error: Error) -> AnalyticsFailureCategory {
        switch error {
        case LoginError.networkError(let underlying): .init(error: underlying)
        case LoginError.missingIDToken, LoginError.missingAuthorizationCode: .sdk
        case LoginError.tokenPersistenceFailed: .unknown
        default: .init(error: error)
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
        context.invalidate()
        tokenStorage.clear()
        appState.logout()
        analytics.record(.guestStarted(flowID: context.flowID), from: .login)
    }
}
