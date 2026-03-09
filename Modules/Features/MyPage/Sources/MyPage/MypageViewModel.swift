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
public class MypageViewModel: ObservableObject, ErrorHandling {
    @Published var activeNavigation: String?

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
    private var timerTask: Task<Void, Never>?
    @Published public var isShowPopup: Bool = false

    @Published public var oldPassword: String = ""
    @Published public var newPassword: String = ""
    @Published public var checkedPassword: String = ""
    @Published public var isPasswordUpdateSuccess: Bool = false
    @Published public var isPhoneUpdateSuccess: Bool = false
    @Published public var passwordError: String?
    @Published public var showPasswordSuccess: Bool = false
    @Published public var showPhoneNumberSuccess: Bool = false
    @Published public var currentError: AppError?
    @Published public var isInterestUpdating: Bool = false

    private let useCase: UserUseCase
    private let profileUseCase: ProfileUseCase

    public init(useCase: UserUseCase, profileUseCase: ProfileUseCase) {
        self.useCase = useCase
        self.profileUseCase = profileUseCase
    }

    public func fetchuserInfo() async {
        await performAsync(feature: "mypage", operation: "fetchUserInfo") {
            user = try await profileUseCase.fetchProfile()
        }
    }

    public func updateNickname(nickname: String) async {
        await performAsync(feature: "mypage", operation: "updateNickname") {
            try await profileUseCase.updateNickname(nickname)

            // UI 상태 업데이트
            if let currentUser = user {
                user = User(
                    id: currentUser.id,
                    loginId: currentUser.loginId,
                    phoneNumber: currentUser.phoneNumber,
                    subscribeEmail: currentUser.subscribeEmail,
                    nickname: nickname,
                    birthYear: currentUser.birthYear,
                    gender: currentUser.gender,
                    createdAt: currentUser.createdAt,
                    industryId: currentUser.industryId,
                    interests: currentUser.interests
                )
            }

            showNicknameSuccess = true
        }
    }

    public func updateIndustry(id: Int) async {
        await performAsync(feature: "mypage", operation: "updateIndustry") {
            try await profileUseCase.updateIndustry(id)

            // UI 상태 업데이트
            if let currentUser = user {
                user = User(
                    id: currentUser.id,
                    loginId: currentUser.loginId,
                    phoneNumber: currentUser.phoneNumber,
                    subscribeEmail: currentUser.subscribeEmail,
                    nickname: currentUser.nickname,
                    birthYear: currentUser.birthYear,
                    gender: currentUser.gender,
                    createdAt: currentUser.createdAt,
                    industryId: id,
                    interests: currentUser.interests
                )
            }

            showIndustrySuccess = true
        }
    }

    public func updateInterests(ids: [Int]) async {
        isInterestUpdating = true
        await performAsync(feature: "mypage", operation: "updateInterests") {
            try await profileUseCase.updateInterests(ids)

            // UI 상태 업데이트
            if let currentUser = user {
                let updatedInterests = ids.map { Interest(id: $0, name: SelectableItemStore.shared.name(for: $0, in: .interest) ?? "") }
                user = User(
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
            }

            showInterestSuccess = true
        }
        isInterestUpdating = false
    }

    public func updatePhoneNumber() async {
        // 인증번호 검증
        guard verifyCode() else {
            showError = true
            isPhoneUpdateSuccess = false
            return
        }

        do {
            try await useCase.updatePhoneNumber(phoneNumber)
            isPhoneUpdateSuccess = true
            showPhoneNumberSuccess = true
        } catch {
            isPhoneUpdateSuccess = false
            handleError(error, feature: "mypage", operation: "updatePhoneNumber")
        }
    }

    public func updatePassword() async {
        do {
            try await profileUseCase.updatePassword(prevPassword: oldPassword, newPassword: newPassword)

            isPasswordUpdateSuccess = true
            oldPassword = ""
            newPassword = ""
            checkedPassword = ""
            showPasswordSuccess = true
        } catch {
            isPasswordUpdateSuccess = false
            passwordError = "현재 비밀번호가 일치하지 않습니다"
            handleError(error, feature: "mypage", operation: "updatePassword")
        }
    }

    public func sendVerificationCode() async {
        guard resendFailureCount < 3 else {
            isShowPopup = true
            return
        }

        defer { resendFailureCount += 1 }

        await performAsync(feature: "mypage", operation: "sendVerificationCode") {
            let response = try await useCase.authSMS(phoneNumber: phoneNumber)
            verificationCode = String(response.code)
            isRequestSent = true

            // 타이머 시작
            timerRemaining = 180 // 3분 = 180초
            startTimer()
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
        timerTask = Task {
            while !Task.isCancelled && timerRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                timerRemaining -= 1
            }
            if timerRemaining <= 0 {
                showError = true
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
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
