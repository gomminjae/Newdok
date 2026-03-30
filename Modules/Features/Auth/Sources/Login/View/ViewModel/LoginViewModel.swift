import SwiftUI
import Combine
import AuthDomain
import Shared

@MainActor
public protocol LoginViewModelBindable: ObservableObject {
    var loginId: String { get set }
    var password: String { get set }

    var isUserIdValid: Bool { get set }
    var isUserPwdValid: Bool { get set }

    var errorMessage: String? { get }
    var isLoading: Bool { get }

    func login(onSuccess: @escaping () -> Void)
}

@MainActor
public final class LoginViewModel: LoginViewModelBindable, ErrorHandling {
    private let loginUseCase: LoginUseCase
    private let authState: Authenticatable

    @Published public var loginId: String
    @Published public var password: String
    @Published public var isUserIdValid: Bool
    @Published public var isUserPwdValid: Bool
    @Published public var errorMessage: String?
    @Published public var isLoading: Bool
    @Published public var isSecurePassword: Bool = true
    @Published public var user: AuthUser?
    @Published public var isLoginIdError: Bool = false
    @Published public var isPasswordError: Bool = false
    @Published public var currentError: AppError?

    public init(
        loginUseCase: LoginUseCase,
        authState: Authenticatable
    ) {
        self.loginUseCase = loginUseCase
        self.authState = authState
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
                self.user = user

                errorMessage = nil
                isLoginIdError = false
                isPasswordError = false

                authState.login()
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
