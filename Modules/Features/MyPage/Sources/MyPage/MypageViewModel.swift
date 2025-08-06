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
    @Published public var isPasswordUpdateSuccess: Bool = false
    @Published public var isPhoneUpdateSuccess: Bool = false
    @Published public var passwordError: String? = nil
    
    
    
    private let useCase: UserUseCase
    
    public init(useCase: UserUseCase) {
        self.useCase = useCase
    }
    
    public func fetchuserInfo() async {
        print("🔄 [MypageViewModel] 프로필 조회 시작")
        do {
            let response = try await useCase.getProfile()
            print("✅ [MypageViewModel] 프로필 조회 성공")
            print("  - id: \(response.id)")
            print("  - nickname: \(response.nickname)")
            print("  - subscribeEmail: \(response.subscribeEmail ?? "nil")")
            
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
            print("💾 [MypageViewModel] UserInfoStore 저장 완료")
        } catch {
            print("❌ [MypageViewModel] 프로필 조회 실패: \(error)")
        }
    }
    
    
    
    public func updateNickname(nickname: String) async {
        print("🔄 [MypageViewModel] 닉네임 변경 시작: \(nickname)")
        do {
            try await useCase.updateNickname(nickname)
            print("✅ [MypageViewModel] 닉네임 변경 성공")
            
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
                print("💾 [MypageViewModel] UserInfoStore 닉네임 업데이트 완료")
            }
        } catch {
            print("❌ [MypageViewModel] 닉네임 변경 실패: \(error)")
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
            print("✅ [MypageViewModel] 휴대폰 번호 변경 성공")
            
            // 성공 시 플래그 설정
            isPhoneUpdateSuccess = true
            
            // 성공 토스트 표시
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .showToast, object: "휴대폰 번호가 변경되었습니다.")
            }
        } catch {
            print("❌ [MypageViewModel] 휴대폰 번호 변경 실패: \(error)")
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
            
            print("🔄 [MypageViewModel] 비밀번호 변경 시작")
            print("  - loginId: \(loginId)")
            print("  - oldPassword: \(oldPassword)")
            print("  - newPassword: \(newPassword)")
            
            try await useCase.updatePassword(loginId: loginId, prevPassword: oldPassword, newPassword: newPassword)
            print("✅ [MypageViewModel] 비밀번호 변경 성공")
            
            // 성공 시 플래그 설정
            isPasswordUpdateSuccess = true
            
            // 입력 필드 초기화
            oldPassword = ""
            newPassword = ""
            checkedPassword = ""
        } catch {
            print("❌ [MypageViewModel] 비밀번호 변경 실패: \(error)")
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
        
        do {
            let response = try await useCase.authSMS(phoneNumber: phoneNumber)
            verificationCode = String(response.code)
            isRequestSent = true
            
            // 타이머 시작
            timerRemaining = 180 // 3분 = 180초
            startTimer()
            
            print("✅ [MypageViewModel] 인증번호 전송 성공, 타이머 시작")
        } catch {
            print("❌ [MypageViewModel] 인증번호 전송 실패: \(error)")
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
