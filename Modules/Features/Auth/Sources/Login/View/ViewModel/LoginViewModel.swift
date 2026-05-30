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
    private let tokenStorage: TokenStorageProtocol
    private let appState: AppState

    public var loginId: String
    public var password: String
    public var isUserIdValid: Bool
    public var isUserPwdValid: Bool
    public var errorMessage: String?
    public var isLoading: Bool
    public var isSecurePassword: Bool = true
    public var user: AuthUser?
    public var isLoginIdError: Bool = false
    public var isPasswordError: Bool = false
    public var currentError: AppError?

    public init(
        loginUseCase: LoginUseCase,
        tokenStorage: TokenStorageProtocol,
        appState: AppState
    ) {
        self.loginUseCase = loginUseCase
        self.tokenStorage = tokenStorage
        self.appState = appState
        self.loginId = ""
        self.password = ""
        self.isUserIdValid = false
        self.isUserPwdValid = false
        self.isLoading = false
        self.errorMessage = nil
    }

    public func login(onSuccess: @escaping () -> Void) {
        guard !isLoading else { return }
        isLoading = true

        Task {
            defer { isLoading = false }

            do {
                _ = try await loginUseCase.execute(loginId: loginId, password: password)

                errorMessage = nil
                isLoginIdError = false
                isPasswordError = false

                appState.login()
                onSuccess()
            } catch let error as LoginError {
                handleLoginError(error)
            } catch {
                errorMessage = "로그인에 실패했습니다"
                isPasswordError = false
                isLoginIdError = false
                handleError(error, feature: "login", operation: "login")
            }
        }
    }

    private func handleLoginError(_ error: LoginError) {
        switch error {
        case .invalidPassword:
            errorMessage = error.localizedDescription
            isPasswordError = true
            isLoginIdError = false
        case .accountNotFound:
            errorMessage = error.localizedDescription
            isLoginIdError = true
            isPasswordError = false
        case .networkError(let underlying):
            isPasswordError = false
            isLoginIdError = false
            handleError(underlying, feature: "login", operation: "login")
            return
        }
        currentError = .userMessage(error.localizedDescription)
    }

    public var isLoginEnabled: Bool {
        !loginId.isEmpty && !password.isEmpty
    }

    public func loginAsGuest() {
        tokenStorage.clear()
        appState.logout()
    }
}
