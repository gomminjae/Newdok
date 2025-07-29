//
//  LoginViewModelResult.swift
//  Auth
//
//  Created by AI Assistant on 1/14/25.
//

import SwiftUI
import Combine
import Domain
import Core
import Shared

@MainActor
public final class LoginViewModelResult: ObservableObject {
    
    // MARK: - Dependencies
    private let userUseCase: UserUseCaseResult
    
    // MARK: - Published Properties
    @Published public var loginId: String = ""
    @Published public var password: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var isSecurePassword: Bool = true
    
    // MARK: - Validation States
    @Published public var loginIdValidation: AppResult<String>?
    @Published public var passwordValidation: AppResult<String>?
    @Published public var isLoginIdError: Bool = false
    @Published public var isPasswordError: Bool = false
    
    // MARK: - User Data
    @Published public var user: User?
    
    // MARK: - AppStorage
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    @AppStorage("isGuest") public var isGuest: Bool = false
    @AppStorage("nickname") public var nickname: String = ""
    @AppStorage("email") public var email: String = ""
    
    // MARK: - Initialization
    public init(userUseCase: UserUseCaseResult) {
        self.userUseCase = userUseCase
        setupValidation()
    }
    
    // MARK: - Validation Setup
    private func setupValidation() {
        // LoginId 실시간 검증
        $loginId
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] loginId in
                self?.validateLoginId(loginId)
            }
            .store(in: &cancellables)
        
        // Password 실시간 검증  
        $password
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] password in
                self?.validatePassword(password)
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Validation Methods
    private func validateLoginId(_ loginId: String) {
        guard !loginId.isEmpty else {
            loginIdValidation = nil
            isLoginIdError = false
            return
        }
        
        loginIdValidation = userUseCase.validateLoginId(loginId)
        
        if case .failure = loginIdValidation {
            isLoginIdError = true
        } else {
            isLoginIdError = false
        }
    }
    
    private func validatePassword(_ password: String) {
        guard !password.isEmpty else {
            passwordValidation = nil
            isPasswordError = false
            return
        }
        
        if password.count < 6 {
            passwordValidation = .failure(.validation(.tooShort("비밀번호")))
            isPasswordError = true
        } else {
            passwordValidation = .success(password)
            isPasswordError = false
        }
    }
    
    // MARK: - Public Methods
    public func login(onSuccess: @escaping () -> Void) {
        Task {
            await performLogin(onSuccess: onSuccess)
        }
    }
    
    private func performLogin(onSuccess: @escaping () -> Void) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            isLoginIdError = false
            isPasswordError = false
        }
        
        let result = await userUseCase.login(loginId: loginId, password: password)
        
        await result
            .onSuccess { [weak self] userInfo in
                await self?.handleLoginSuccess(userInfo: userInfo, onSuccess: onSuccess)
            }
            .onFailure { [weak self] error in
                await self?.handleLoginFailure(error: error)
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    @MainActor
    private func handleLoginSuccess(userInfo: (User, String), onSuccess: @escaping () -> Void) async {
        let (user, token) = userInfo
        
        // 토큰 저장
        TokenStorage.accessToken = token
        
        // 사용자 정보 저장
        self.user = user
        nickname = user.nickname
        email = user.subscribeEmail
        isLoggedIn = true
        isGuest = false
        
        // UserInfoStore에 저장
        let userInfo = UserInfo(
            id: user.id,
            loginId: user.loginId,
            phoneNumber: user.phoneNumber,
            subscribeEmail: user.subscribeEmail,
            nickname: user.nickname,
            birthYear: user.birthYear,
            gender: user.gender,
            createdAt: user.createdAt,
            industryId: user.industryId,
            interestIds: user.interests.map { $0.id }
        )
        
        UserInfoStore.shared.save(userInfo)
        
        // 성공 콜백 실행
        onSuccess()
    }
    
    @MainActor
    private func handleLoginFailure(error: AppError) async {
        switch error {
        case .network(let networkError):
            switch networkError {
            case .serverError(let statusCode, let message):
                if statusCode == 400 {
                    let errorMessage = message ?? ""
                    if errorMessage.contains("비밀번호") {
                        self.errorMessage = "비밀번호가 일치하지 않습니다"
                        isPasswordError = true
                    } else if errorMessage.contains("계정") {
                        self.errorMessage = "등록되지 않은 계정이거나, 아이디를 다시 확인해주세요"
                        isLoginIdError = true
                    } else {
                        self.errorMessage = errorMessage
                    }
                } else {
                    self.errorMessage = "서버 오류가 발생했습니다"
                }
            case .networkUnavailable:
                self.errorMessage = "네트워크 연결을 확인해주세요"
            case .timeout:
                self.errorMessage = "요청 시간이 초과되었습니다"
            case .unknown(let message):
                self.errorMessage = message
            }
        case .validation(let validationError):
            switch validationError {
            case .emptyField(let field):
                self.errorMessage = "\(field)을(를) 입력해주세요"
            case .invalidFormat(let field):
                self.errorMessage = "\(field) 형식이 올바르지 않습니다"
            case .tooShort(let field):
                self.errorMessage = "\(field)이(가) 너무 짧습니다"
            case .tooLong(let field):
                self.errorMessage = "\(field)이(가) 너무 깁니다"
            }
        case .business(let businessError):
            switch businessError {
            case .userNotFound:
                self.errorMessage = "사용자를 찾을 수 없습니다"
                isLoginIdError = true
            case .invalidCredentials:
                self.errorMessage = "아이디 또는 비밀번호가 올바르지 않습니다"
                isPasswordError = true
            case .accountLocked:
                self.errorMessage = "계정이 잠겨있습니다"
            case .operationNotAllowed:
                self.errorMessage = "허용되지 않은 작업입니다"
            case .dataNotFound:
                self.errorMessage = "데이터를 찾을 수 없습니다"
            }
        case .unknown(let message):
            self.errorMessage = message.isEmpty ? "알 수 없는 오류가 발생했습니다" : message
        }
    }
    
    // MARK: - Computed Properties
    public var isLoginEnabled: Bool {
        !loginId.isEmpty && 
        !password.isEmpty && 
        !isLoginIdError && 
        !isPasswordError &&
        !isLoading
    }
    
    public var loginIdValidationMessage: (text: String, color: Color)? {
        guard let validation = loginIdValidation else { return nil }
        
        switch validation {
        case .success:
            return (text: "사용 가능한 형식입니다", color: Color(hex: "#2866D3"))
        case .failure(let error):
            return (text: error.localizedDescription, color: Color(hex: "#E32727"))
        }
    }
    
    public var passwordValidationMessage: (text: String, color: Color)? {
        guard let validation = passwordValidation else { return nil }
        
        switch validation {
        case .success:
            return (text: "사용 가능한 비밀번호입니다", color: Color(hex: "#2866D3"))
        case .failure(let error):
            return (text: error.localizedDescription, color: Color(hex: "#E32727"))
        }
    }
} 