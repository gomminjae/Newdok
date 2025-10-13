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
    @Published public var showNicknameSuccess: Bool = false
    @Published public var showIndustrySuccess: Bool = false
    @Published public var showInterestSuccess: Bool = false

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
    @Published public var isPasswordUpdateSuccess: Bool = false
    @Published public var isPhoneUpdateSuccess: Bool = false
    @Published public var passwordError: String? = nil
    @Published public var showPasswordSuccess: Bool = false
    @Published public var showPhoneNumberSuccess: Bool = false
    
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
        }
    }
    
    public func updateNickname(nickname: String) async {
        do {
            try await useCase.updateNickname(nickname)
            
            // UserInfoStore 즉시 업데이트
            if let currentUser = user {
                let updatedUserInfo = UserInfo(
                    id: currentUser.id,
                    loginId: currentUser.loginId,
                    phoneNumber: currentUser.phoneNumber,
                    subscribeEmail: currentUser.subscribeEmail,
                    nickname: nickname, // 변경된 닉네임 사용
                    birthYear: currentUser.birthYear,
                    gender: currentUser.gender,
                    createdAt: currentUser.createdAt,
                    industryId: currentUser.industryId,
                    interestIds: currentUser.interests.map { $0.id }
                )
                UserInfoStore.shared.save(updatedUserInfo)
            }
            
            showNicknameSuccess = true
        } catch {
        }
    }
    
    public func updateIndustry(id: Int) async {
        do {
            try await useCase.updateIndustry(id)
            
            // UserInfoStore 즉시 업데이트
            if let currentUser = user {
                let updatedUserInfo = UserInfo(
                    id: currentUser.id,
                    loginId: currentUser.loginId,
                    phoneNumber: currentUser.phoneNumber,
                    subscribeEmail: currentUser.subscribeEmail,
                    nickname: currentUser.nickname,
                    birthYear: currentUser.birthYear,
                    gender: currentUser.gender,
                    createdAt: currentUser.createdAt,
                    industryId: id, // 변경된 종사산업 ID 사용
                    interestIds: currentUser.interests.map { $0.id }
                )
                UserInfoStore.shared.save(updatedUserInfo)
                
                // 새로운 User 객체 생성하여 할당
                let updatedUser = User(
                    id: currentUser.id,
                    loginId: currentUser.loginId,
                    phoneNumber: currentUser.phoneNumber,
                    subscribeEmail: currentUser.subscribeEmail,
                    nickname: currentUser.nickname,
                    birthYear: currentUser.birthYear,
                    gender: currentUser.gender,
                    createdAt: currentUser.createdAt,
                    industryId: id, // 변경된 종사산업 ID 사용
                    interests: currentUser.interests
                )
                user = updatedUser
            }
            
            showIndustrySuccess = true
        } catch {
        }
    }
    
    public func updateInterests(ids: [Int]) async {
        do {
            try await useCase.updateInterest(ids)
            
            // UserInfoStore 즉시 업데이트
            if let currentUser = user {
                let updatedUserInfo = UserInfo(
                    id: currentUser.id,
                    loginId: currentUser.loginId,
                    phoneNumber: currentUser.phoneNumber,
                    subscribeEmail: currentUser.subscribeEmail,
                    nickname: currentUser.nickname,
                    birthYear: currentUser.birthYear,
                    gender: currentUser.gender,
                    createdAt: currentUser.createdAt,
                    industryId: currentUser.industryId,
                    interestIds: ids // 변경된 관심사 ID들 사용
                )
                UserInfoStore.shared.save(updatedUserInfo)
                
                // 새로운 User 객체 생성하여 할당
                let updatedInterests = ids.map { Interest(id: $0, name: SelectableItemStore.shared.name(for: $0, in: .interest) ?? "") }
                let updatedUser = User(
                    id: currentUser.id,
                    loginId: currentUser.loginId,
                    phoneNumber: currentUser.phoneNumber,
                    subscribeEmail: currentUser.subscribeEmail,
                    nickname: currentUser.nickname,
                    birthYear: currentUser.birthYear,
                    gender: currentUser.gender,
                    createdAt: currentUser.createdAt,
                    industryId: currentUser.industryId ?? 0,
                    interests: updatedInterests
                )
                user = updatedUser
            }
            
            showInterestSuccess = true
        } catch {
        }
    }
    
    public func updatePhoneNumber() async {
        do {
            
            // 인증번호 검증
            guard verifyCode() else {
                showError = true
                isPhoneUpdateSuccess = false
                return
            }
            
            try await useCase.updatePhoneNumber(phoneNumber)
            
            // 성공 시 플래그 설정
            isPhoneUpdateSuccess = true
            showPhoneNumberSuccess = true
        } catch {
            isPhoneUpdateSuccess = false
            
            // 실패 토스트 표시
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .showToast, object: "휴대폰 번호 변경에 실패했습니다.")
            }
        }
    }
    
    public func updatePassword() async {
        do {
            // UserInfoStore에서 loginId 가져오기
            let userInfo = UserInfoStore.shared.load()
            let loginId = userInfo?.loginId ?? user?.loginId ?? ""
            
            
            try await useCase.updatePassword(loginId: loginId, prevPassword: oldPassword, newPassword: newPassword)
            
            // 성공 시 플래그 설정
            isPasswordUpdateSuccess = true
            
            // 입력 필드 초기화
            oldPassword = ""
            newPassword = ""
            checkedPassword = ""
            
            showPasswordSuccess = true
        } catch {
            isPasswordUpdateSuccess = false
            
            // 에러 메시지 설정
            passwordError = "현재 비밀번호가 일치하지 않습니다"
        }
    }
    
    public func sendVerificationCode() async {
        guard resendFailureCount < 3 else {
            isShowPopup = true
            return
        }

        defer { resendFailureCount += 1 }

        do {
            let response = try await useCase.authSMS(phoneNumber: phoneNumber)
            verificationCode = String(response.code)
            isRequestSent = true

            // 타이머 시작
            timerRemaining = 180 // 3분 = 180초
            startTimer()

        } catch {
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
