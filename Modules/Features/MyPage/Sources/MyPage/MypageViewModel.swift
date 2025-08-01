//
//  MypageViewModel.swift
//  Mypage
//
//  Created by 권민재 on 5/9/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import Combine
import Domain
import Shared

protocol MypageViewModelBindable {
    
}

@MainActor
public class MypageViewModel: ObservableObject {
    
    @Published var activeNavigation: String? = nil
    
    @Published var nickname: String = ""
    @Published var user: User?
    
    @Published var shownicknameToast: Bool = false
    @Published var showIndustryToast: Bool = false
    @Published var showInterestToast: Bool = false
    
    
    @Published var phoneNumber: String = ""
    @Published public var isRequestSent = false
    @Published public var isTimerActive = false
    @Published public var timerRemaining = 180
    @Published public var showAlreadyRegisteredAlert = false
    @Published public var showError = false
    @Published public var enteredVerificationCode: String = ""
    private var verificationCode: String = ""
    @Published public var resendFailureCount: Int = 0
    private var timer: Timer?
    @Published public var isShowPopup: Bool = false
    
    
    @Published public var oldPassword: String = ""
    @Published public var newPassword: String = ""
    @Published public var checkedPassword: String = ""
    
    
    
    private let useCase: UserUseCase
    
    public init(useCase: UserUseCase) {
        self.useCase = useCase
    }
    
    public func fetchuserInfo() async {
        do {
            let response = try await useCase.getProfile()
            user = response
            
            // UserInfoStore 업데이트
            let userInfo = UserInfo(
                id: response.id,
                loginId: response.loginId,
                phoneNumber: response.phoneNumber,
                subscribeEmail: response.subscribeEmail,
                nickname: response.nickname,
                birthYear: response.birthYear,
                gender: response.gender,
                createdAt: response.createdAt,
                industryId: response.industryId,
                interestIds: response.interests.map { $0.id }
            )
            UserInfoStore.shared.save(userInfo)
        } catch {
            print("프로필 조회 실패")
        }
    }
    
    
    
    public func updateNickname(nickname: String) async {
        do {
            try await useCase.updateNickname(nickname)
        } catch {
            print("닉네임 변경 실패")
        }
    }
    

    
    public func updateIndustry(id: Int) async {
        do {
            try await useCase.updateIndustry(id)
        } catch {
            print("산업 변경 실패")
        }
    }
    
    public func updateInterests(ids: [Int]) async {
        do {
            try await useCase.updateInterest(ids)
        } catch {
            print("관심사 변경 실패")
        }
    }
    
    public func updatePhoneNumber() async {
        do {
            try await useCase.updatePhoneNumber(phoneNumber)
        } catch {
            print("비밀번호 변경실패")
        }
    }
    
    public func updatePassword() async {
        do {
            try await useCase.updatePassword(loginId: user?.loginId ?? "", prevPassword: oldPassword, newPassword: newPassword)
        } catch {
            print("패스워드 변경 오류")
        }
    }
    
    
    public func sendVerificationCode() async {
        guard resendFailureCount < 3 else {
            isShowPopup = true
            return
        }
        
        do {
            let response = try await useCase.authSMS(phoneNumber: phoneNumber)
            verificationCode = String(response.code)
            isRequestSent = true
        } catch {
            print("번호가 안보내짐")
        }
    }

    func verifyCode() -> Bool {
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
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
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
    }
    
    public var isOldPasswordValid: Bool {
        return oldPassword.count >= 8
    }

    public var isNewPasswordValid: Bool {
        return newPassword.count >= 8
    }

    public var isNewPasswordConfirmed: Bool {
        return newPassword == checkedPassword
    }

    public var isPasswordValid: Bool {
        return isOldPasswordValid && isNewPasswordValid && isNewPasswordConfirmed
    }
    
    public var oldPasswordError: String? {
        if oldPassword.isEmpty || isOldPasswordValid { return nil }
        return "8자 이상의 비밀번호를 입력해주세요."
    }

    public var newPasswordError: String? {
        if newPassword.isEmpty || isNewPasswordValid { return nil }
        return "8자 이상의 비밀번호를 입력해주세요."
    }

    public var confirmPasswordError: String? {
        if checkedPassword.isEmpty || isNewPasswordConfirmed { return nil }
        return "비밀번호가 일치하지 않습니다."
    }
    
    
    
    
}
