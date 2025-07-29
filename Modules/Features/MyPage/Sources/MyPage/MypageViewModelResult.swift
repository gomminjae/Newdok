//
//  MypageViewModelResult.swift
//  Mypage
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation
import Combine
import Domain
import Shared
import SwiftUI

@MainActor
public class MypageViewModelResult: ObservableObject {
    
    // MARK: - Dependencies
    private let useCase: UserUseCaseResult
    
    // MARK: - Published Properties
    @Published public var activeNavigation: String? = nil
    @Published public var nickname: String = ""
    @Published public var user: User?
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    // Toast 상태
    @Published public var shownicknameToast: Bool = false
    @Published public var showIndustryToast: Bool = false
    @Published public var showInterestToast: Bool = false
    
    // 전화번호 인증 관련
    @Published public var phoneNumber: String = ""
    @Published public var isRequestSent = false
    @Published public var isTimerActive = false
    @Published public var timerRemaining = 180
    @Published public var showAlreadyRegisteredAlert = false
    @Published public var showError = false
    @Published public var enteredVerificationCode: String = ""
    @Published public var resendFailureCount: Int = 0
    @Published public var isShowPopup: Bool = false
    private var verificationCode: String = ""
    private var timer: Timer?
    
    // 비밀번호 변경 관련
    @Published public var oldPassword: String = ""
    @Published public var newPassword: String = ""
    @Published public var checkedPassword: String = ""
    
    // MARK: - Initialization
    public init(useCase: UserUseCaseResult) {
        self.useCase = useCase
    }
    
    // MARK: - Public Methods
    public func fetchUserInfo() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.getProfile()
        
        await result
            .onSuccess { [weak self] user in
                await self?.handleUserInfoSuccess(user)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "프로필 조회")
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func updateNickname(nickname: String) async -> AppResult<User> {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.updateNickname(nickname)
        
        await result
            .onSuccess { [weak self] user in
                await self?.handleNicknameUpdateSuccess(user)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "닉네임 변경")
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result
    }
    
    public func updateIndustry(id: Int) async -> AppResult<Void> {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.updateIndustry(id)
        
        await result
            .onSuccess { [weak self] _ in
                await self?.handleIndustryUpdateSuccess()
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "산업 변경")
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result
    }
    
    public func updateInterests(ids: [Int]) async -> AppResult<Void> {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.updateInterest(ids)
        
        await result
            .onSuccess { [weak self] _ in
                await self?.handleInterestUpdateSuccess()
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "관심사 변경")
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result
    }
    
    public func updatePhoneNumber() async -> AppResult<Void> {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.updatePhoneNumber(phoneNumber)
        
        await result
            .onSuccess { [weak self] _ in
                await self?.handlePhoneUpdateSuccess()
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "전화번호 변경")
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result
    }
    
    public func updatePassword() async -> AppResult<Void> {
        guard let loginId = user?.loginId else {
            return .failure(.validation(.emptyField("로그인 ID")))
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.updatePassword(
            loginId: loginId,
            prevPassword: oldPassword,
            newPassword: newPassword
        )
        
        await result
            .onSuccess { [weak self] _ in
                await self?.handlePasswordUpdateSuccess()
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "비밀번호 변경")
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result
    }
    
    public func sendVerificationCode() async -> AppResult<Void> {
        guard resendFailureCount < 3 else {
            await MainActor.run {
                isShowPopup = true
            }
            return .failure(.business(.operationNotAllowed))
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.authSMS(phoneNumber: phoneNumber)
        
        await result
            .onSuccess { [weak self] smsResponse in
                await self?.handleSMSSuccess(smsResponse)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "인증번호 발송")
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result.map { _ in () }
    }
    
    public func verifyCode() -> Bool {
        guard isRequestSent else { return false }
        
        if timerRemaining <= 0 {
            showError = true
            return false
        }
        
        if enteredVerificationCode == verificationCode {
            stopTimer()
            return true
        } else {
            showError = true
            return false
        }
    }
    
    public func refreshData() async {
        await fetchUserInfo()
    }
    
    // MARK: - Private Methods
    @MainActor
    private func handleUserInfoSuccess(_ user: User) async {
        self.user = user
        self.nickname = user.nickname
    }
    
    @MainActor
    private func handleNicknameUpdateSuccess(_ user: User) async {
        self.user = user
        self.nickname = user.nickname
        self.shownicknameToast = true
    }
    
    @MainActor
    private func handleIndustryUpdateSuccess() async {
        self.showIndustryToast = true
    }
    
    @MainActor
    private func handleInterestUpdateSuccess() async {
        self.showInterestToast = true
    }
    
    @MainActor
    private func handlePhoneUpdateSuccess() async {
        // 전화번호 업데이트 성공 처리
    }
    
    @MainActor
    private func handlePasswordUpdateSuccess() async {
        // 비밀번호 변경 성공 후 필드 초기화
        self.oldPassword = ""
        self.newPassword = ""
        self.checkedPassword = ""
    }
    
    @MainActor
    private func handleSMSSuccess(_ smsResponse: SMSResponse) async {
        self.verificationCode = String(smsResponse.code)
        self.isRequestSent = true
        startTimer()
    }
    
    @MainActor
    private func handleError(_ error: AppError, context: String) async {
        switch error {
        case .network(let networkError):
            switch networkError {
            case .networkUnavailable:
                self.errorMessage = "네트워크 연결을 확인해주세요"
            case .timeout:
                self.errorMessage = "요청 시간이 초과되었습니다"
            case .serverError(let statusCode, let message):
                if statusCode == 400 && context == "닉네임 변경" {
                    self.errorMessage = "이미 사용중인 닉네임입니다"
                } else if statusCode == 400 && context == "비밀번호 변경" {
                    self.errorMessage = "현재 비밀번호가 일치하지 않습니다"
                } else {
                    self.errorMessage = "서버 오류가 발생했습니다"
                }
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
                self.errorMessage = "사용자 정보를 찾을 수 없습니다"
            case .invalidCredentials:
                self.errorMessage = "인증 정보가 올바르지 않습니다"
            case .operationNotAllowed:
                if context == "인증번호 발송" {
                    self.errorMessage = "인증번호 재전송 횟수를 초과했습니다"
                } else {
                    self.errorMessage = "권한이 없습니다"
                }
            case .dataNotFound:
                self.errorMessage = "데이터를 찾을 수 없습니다"
            case .accountLocked:
                self.errorMessage = "계정이 잠겨있습니다"
            }
        case .unknown(let message):
            self.errorMessage = message.isEmpty ? "\(context) 처리 중 오류가 발생했습니다" : message
        }
        
        print("❌ \(context) 실패: \(error)")
    }
    
    // MARK: - Timer Methods
    private func startTimer() {
        stopTimer()
        isTimerActive = true
        timerRemaining = 180
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.timerRemaining -= 1
                if self.timerRemaining <= 0 {
                    self.stopTimer()
                    self.showError = true
                    self.resendFailureCount += 1
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
    }
    
    deinit {
        stopTimer()
    }
} 