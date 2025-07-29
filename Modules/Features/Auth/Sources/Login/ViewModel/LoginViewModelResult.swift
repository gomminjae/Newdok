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
    @Published public var isSecurePassword: Bool = true
    
    // MARK: - Validation States
    @Published public var loginIdValidation: AppResult<String>?
    @Published public var passwordValidation: AppResult<String>?
    
    // MARK: - UI States
    @Published public var showErrorAlert: Bool = false
    @Published public var errorMessage: String = ""
    @Published public var showSuccessToast: Bool = false
    @Published public var successMessage: String = ""
    
    // MARK: - AppStorage
    @AppStorage("isLoggedIn") public var isLoggedIn: Bool = false
    @AppStorage("isGuest") public var isGuest: Bool = false
    @AppStorage("nickname") public var nickname: String = ""
    @AppStorage("email") public var email: String = ""
    
    // MARK: - Computed Properties
    public var isLoginEnabled: Bool {
        return !loginId.isEmpty && 
               !password.isEmpty && 
               !isLoading &&
               (loginIdValidation?.isSuccess ?? false)
    }
    
    public var loginIdErrorMessage: String? {
        if case .failure(let error) = loginIdValidation {
            return error.localizedDescription
        }
        return nil
    }
    
    public var isLoginIdErrorState: Bool {
        guard !loginId.isEmpty else { return false }
        return loginIdValidation?.isFailure ?? false
    }
    
    // MARK: - Initialization
    public init(userUseCase: UserUseCaseResult) {
        self.userUseCase = userUseCase
        
        // 개발 환경에서만 테스트 값 설정
        #if DEBUG
        self.loginId = ""
        self.password = ""
        #endif
        
        setupValidation()
    }
    
    // MARK: - Validation Setup
    private func setupValidation() {
        // loginId 실시간 검증
        $loginId
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { [weak self] id in
                guard let self = self else { return nil }
                guard !id.isEmpty else { return nil }
                return self.userUseCase.validateLoginId(id)
            }
            .assign(to: &$loginIdValidation)
    }
    
    // MARK: - Public Methods
    
    /// 로그인 시도
    public func login(onSuccess: @escaping () -> Void) {
        Task {
            await performLogin(onSuccess: onSuccess)
        }
    }
    
    /// ID 중복 확인
    public func checkIDDuplicate() {
        guard let validation = loginIdValidation,
              case .success(let validId) = validation else {
            return
        }
        
        Task {
            await performIDCheck(validId)
        }
    }
    
    /// 게스트로 계속하기
    public func continueAsGuest(onSuccess: @escaping () -> Void) {
        isGuest = true
        isLoggedIn = false
        nickname = "게스트"
        email = ""
        
        DispatchQueue.main.async {
            onSuccess()
        }
    }
    
    /// 폼 초기화
    public func resetForm() {
        loginId = ""
        password = ""
        loginIdValidation = nil
        passwordValidation = nil
        errorMessage = ""
        showErrorAlert = false
    }
    
    // MARK: - Private Methods
    
    private func performLogin(onSuccess: @escaping () -> Void) async {
        isLoading = true
        
        let result = await userUseCase.login(loginId: loginId, password: password)
        
        await result
            .onSuccess { [weak self] userInfo in
                guard let self = self else { return }
                self.handleLoginSuccess(userInfo, onSuccess: onSuccess)
            }
            .onFailure { [weak self] error in
                guard let self = self else { return }
                self.handleLoginFailure(error)
            }
        
        isLoading = false
    }
    
    private func performIDCheck(_ loginId: String) async {
        let result = await userUseCase.checkIDDup(loginId)
        
        await result
            .onSuccess { [weak self] checkResult in
                guard let self = self else { return }
                self.handleIDCheckSuccess(checkResult)
            }
            .onFailure { [weak self] error in
                guard let self = self else { return }
                self.handleIDCheckFailure(error)
            }
    }
    
    private func handleLoginSuccess(_ userInfo: (User, String), onSuccess: @escaping () -> Void) {
        let (user, token) = userInfo
        
        // 토큰 저장
        TokenStorage.accessToken = token
        
        // 사용자 정보 저장
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
        
        // UI 상태 업데이트
        isLoggedIn = true
        isGuest = false
        nickname = user.nickname
        email = user.subscribeEmail
        
        successMessage = "로그인이 완료되었습니다."
        showSuccessToast = true
        
        // 성공 콜백 실행
        DispatchQueue.main.async {
            onSuccess()
        }
    }
    
    private func handleLoginFailure(_ error: AppError) {
        errorMessage = error.localizedDescription ?? "로그인에 실패했습니다."
        showErrorAlert = true
    }
    
    private func handleIDCheckSuccess(_ result: CheckResult) {
        // ID 중복 확인 결과 처리
        switch result {
        case .exists:
            loginIdValidation = .failure(.validation(.duplicateValue("아이디")))
        case .notFound:
            loginIdValidation = .success(loginId)
        }
    }
    
    private func handleIDCheckFailure(_ error: AppError) {
        errorMessage = error.localizedDescription ?? "ID 확인 중 오류가 발생했습니다."
        showErrorAlert = true
    }
} 