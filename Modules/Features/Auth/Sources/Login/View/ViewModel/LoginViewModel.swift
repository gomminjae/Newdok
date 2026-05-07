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

    public init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
        self.loginId = ""
        self.password = ""
        self.isUserIdValid = false
        self.isUserPwdValid = false
        self.isLoading = false
        self.errorMessage = nil
    }

    public func login(onSuccess: @escaping () -> Void) {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                let user = try await loginUseCase.execute(loginId: loginId, password: password)

                errorMessage = nil
                isLoginIdError = false
                isPasswordError = false

                AppState.shared.login()
                onSuccess()
            } catch let error as LoginError {
                handleLoginError(error)
                handleError(error, feature: "login", operation: "login")
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
            errorMessage = "비밀번호가 일치하지 않습니다"
            isPasswordError = true
            isLoginIdError = false
        case .accountNotFound:
            errorMessage = "등록되지 않은 계정이거나, 아이디를 다시 확인해주세요"
            isLoginIdError = true
            isPasswordError = false
        case .networkError:
            isPasswordError = false
            isLoginIdError = false
        }
    }

    public var isLoginEnabled: Bool {
        !loginId.isEmpty && !password.isEmpty
    }
}
