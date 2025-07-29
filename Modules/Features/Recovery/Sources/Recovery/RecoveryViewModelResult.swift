//
//  RecoveryViewModelResult.swift
//  Recovery
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation
import Domain
import Shared
import SwiftUI

@MainActor
public class RecoveryViewModelResult: ObservableObject {
    
    // MARK: - Dependencies
    private let userUseCase: UserUseCaseResult
    
    // MARK: - Page Management
    @Published var currentPage: Int = 0
    
    // MARK: - Loading & Error States
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    // MARK: - Find ID
    @Published public var users: [SimpleUser] = []
    @Published public var phoneNumber: String = ""
    
    // MARK: - Password Reset
    @Published public var password: String = ""
    @Published public var checkPassword: String = ""
    @Published public var loginID: String = ""
    @Published var passwordRecoveryStep: Int = 0 // 0: 아이디, 1: 인증, 2: 비번입력, 3: 완료
    @Published var recoveryId: String = ""
    @Published var recoveryPhone: String = ""
    @Published var recoveryCode: String = ""
    @Published var recoveryCodeSent: Bool = false
    @Published var recoveryCodeVerified: Bool? = nil // nil: 미시도, true: 성공, false: 실패
    @Published var newPassword: String = ""
    @Published var newPasswordCheck: String = ""
    @Published var passwordResetSuccess: Bool? = nil
    @Published var recoveryErrorMessage: String? = nil
    
    // 인증번호 저장용
    @Published var sentCode: String = ""
    
    // MARK: - Initialization
    public init(useCase: UserUseCaseResult) {
        self.userUseCase = useCase
    }
    
    // MARK: - Find ID Methods
    public func findMyIds() async -> AppResult<[SimpleUser]> {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await userUseCase.checkPhoneNumber(phoneNumber)
        
        await result
            .onSuccess { [weak self] users in
                await self?.handleFindIDSuccess(users)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "아이디 찾기")
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result
    }
    
    // MARK: - Password Recovery Methods
    public func checkIdExists() async -> AppResult<SimpleUser?> {
        await MainActor.run {
            isLoading = true
            recoveryErrorMessage = nil
        }
        
        let result = await userUseCase.checkIDDup(recoveryId)
        
        await result
            .onSuccess { [weak self] checkResult in
                await self?.handleIDExistsSuccess(checkResult)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "아이디 확인")
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result.map { checkResult in
            switch checkResult {
            case .exists(let user):
                return user
            case .notFound:
                return nil
            }
        }
    }
    
    public func sendRecoveryCode() async -> AppResult<Void> {
        await MainActor.run {
            isLoading = true
            recoveryErrorMessage = nil
        }
        
        let result = await userUseCase.authSMS(phoneNumber: recoveryPhone)
        
        await result
            .onSuccess { [weak self] smsResponse in
                await self?.handleRecoveryCodeSuccess(smsResponse)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "인증번호 발송", isRecovery: true)
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result.map { _ in () }
    }
    
    public func verifyRecoveryCode() -> Bool {
        if recoveryCode == sentCode {
            recoveryCodeVerified = true
            return true
        } else {
            recoveryCodeVerified = false
            return false
        }
    }
    
    public func resetPassword() async -> AppResult<Void> {
        await MainActor.run {
            isLoading = true
            recoveryErrorMessage = nil
        }
        
        let result = await userUseCase.updatePassword(
            loginId: recoveryId,
            prevPassword: "", // 비밀번호 재설정은 기존 비밀번호 불필요
            newPassword: newPassword
        )
        
        await result
            .onSuccess { [weak self] _ in
                await self?.handlePasswordResetSuccess()
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "비밀번호 재설정", isRecovery: true)
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result
    }
    
    // MARK: - Navigation Helpers
    public func goToNextRecoveryStep() {
        if passwordRecoveryStep < 3 {
            passwordRecoveryStep += 1
        }
    }
    
    public func goToPreviousRecoveryStep() {
        if passwordRecoveryStep > 0 {
            passwordRecoveryStep -= 1
        }
    }
    
    public func resetRecoveryFlow() {
        passwordRecoveryStep = 0
        recoveryId = ""
        recoveryPhone = ""
        recoveryCode = ""
        recoveryCodeSent = false
        recoveryCodeVerified = nil
        newPassword = ""
        newPasswordCheck = ""
        passwordResetSuccess = nil
        recoveryErrorMessage = nil
        sentCode = ""
    }
    
    // MARK: - Validation Helpers
    public func validateNewPassword() -> Bool {
        return newPassword.count >= 6 && newPassword == newPasswordCheck
    }
    
    public func isRecoveryStepValid() -> Bool {
        switch passwordRecoveryStep {
        case 0:
            return !recoveryId.isEmpty
        case 1:
            return recoveryCodeVerified == true
        case 2:
            return validateNewPassword()
        default:
            return true
        }
    }
    
    // MARK: - Success Handlers
    @MainActor
    private func handleFindIDSuccess(_ users: [SimpleUser]) async {
        self.users = users
    }
    
    @MainActor
    private func handleIDExistsSuccess(_ checkResult: CheckResult<SimpleUser>) async {
        switch checkResult {
        case .exists(_):
            // 아이디가 존재함 - 다음 단계로 진행 가능
            break
        case .notFound:
            recoveryErrorMessage = "등록되지 않은 아이디입니다"
        }
    }
    
    @MainActor
    private func handleRecoveryCodeSuccess(_ smsResponse: SMSResponse) async {
        self.sentCode = String(smsResponse.code)
        self.recoveryCodeSent = true
        self.recoveryErrorMessage = nil
    }
    
    @MainActor
    private func handlePasswordResetSuccess() async {
        self.passwordResetSuccess = true
        goToNextRecoveryStep()
    }
    
    // MARK: - Error Handler
    @MainActor
    private func handleError(_ error: AppError, context: String, isRecovery: Bool = false) async {
        let errorMessage: String
        
        switch error {
        case .network(let networkError):
            switch networkError {
            case .networkUnavailable:
                errorMessage = "네트워크 연결을 확인해주세요"
            case .timeout:
                errorMessage = "요청 시간이 초과되었습니다"
            case .serverError(let statusCode, let message):
                if statusCode == 404 && context == "아이디 확인" {
                    errorMessage = "등록되지 않은 아이디입니다"
                } else if statusCode == 400 && context == "비밀번호 재설정" {
                    errorMessage = "비밀번호 재설정에 실패했습니다"
                } else {
                    errorMessage = message ?? "서버 오류가 발생했습니다"
                }
            case .unknown(let message):
                errorMessage = message
            }
        case .validation(let validationError):
            switch validationError {
            case .emptyField(let field):
                errorMessage = "\(field)을(를) 입력해주세요"
            case .invalidFormat(let field):
                errorMessage = "\(field) 형식이 올바르지 않습니다"
            case .tooShort(let field):
                errorMessage = "\(field)이(가) 너무 짧습니다"
            case .tooLong(let field):
                errorMessage = "\(field)이(가) 너무 깁니다"
            }
        case .business(let businessError):
            switch businessError {
            case .userNotFound:
                if context == "아이디 찾기" {
                    errorMessage = "해당 전화번호로 등록된 계정이 없습니다"
                } else {
                    errorMessage = "사용자를 찾을 수 없습니다"
                }
            case .invalidCredentials:
                errorMessage = "인증 정보가 올바르지 않습니다"
            case .operationNotAllowed:
                errorMessage = "허용되지 않은 작업입니다"
            case .dataNotFound:
                errorMessage = "데이터를 찾을 수 없습니다"
            case .accountLocked:
                errorMessage = "계정이 잠겨있습니다"
            }
        case .unknown(let message):
            errorMessage = message.isEmpty ? "\(context) 처리 중 오류가 발생했습니다" : message
        }
        
        // Recovery 관련 에러는 recoveryErrorMessage에, 일반 에러는 errorMessage에 저장
        if isRecovery {
            self.recoveryErrorMessage = errorMessage
        } else {
            self.errorMessage = errorMessage
        }
        
        print("❌ \(context) 실패: \(error)")
    }
} 