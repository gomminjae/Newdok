//
//  MypageViewModel.swift
//  Mypage
//
//  Created by 권민재 on 5/9/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import MypageDomain
import Shared
import Observation

protocol MypageViewModelBindable {
}

@Observable
@MainActor
public final class MypageViewModel: ErrorHandling {
    var activeNavigation: String?

    var nickname: String = ""
    var user: MypageUser?

    var shownicknameToast: Bool = false
    var showIndustryToast: Bool = false
    var showInterestToast: Bool = false
    public var showNicknameSuccess: Bool = false
    public var showIndustrySuccess: Bool = false
    public var showInterestSuccess: Bool = false

    var phoneNumber: String = ""
    public var isRequestSent = false
    public var isTimerActive = false
    public var timerRemaining = 180
    public var showAlreadyRegisteredAlert = false
    public var showError = false
    public var enteredVerificationCode: String = ""
    private var verificationCode: String = ""
    public var resendFailureCount: Int = 0
    private var timerTask: Task<Void, Never>?
    public var isShowPopup: Bool = false

    public var oldPassword: String = ""
    public var newPassword: String = ""
    public var checkedPassword: String = ""
    public var isPasswordUpdateSuccess: Bool = false
    public var isPhoneUpdateSuccess: Bool = false
    public var passwordError: String?
    public var showPasswordSuccess: Bool = false
    public var showPhoneNumberSuccess: Bool = false
    public var currentError: AppError?
    public var isNicknameUpdating: Bool = false
    public var isIndustryUpdating: Bool = false
    public var isInterestUpdating: Bool = false
    public var isPhoneUpdating: Bool = false
    public var isPasswordUpdating: Bool = false
    public var isVerificationSending: Bool = false

    private let fetchProfileUseCase: FetchMypageProfileUseCase
    private let updateNicknameUseCase: UpdateMypageNicknameUseCase
    private let updatePasswordUseCase: UpdateMypagePasswordUseCase
    private let updateInterestsUseCase: UpdateMypageInterestsUseCase
    private let updateIndustryUseCase: UpdateMypageIndustryUseCase
    private let updatePhoneNumberUseCase: UpdateMypagePhoneNumberUseCase
    private let authSMSUseCase: MypageAuthSMSUseCase
    private let selectableItemStore: SelectableItemStoreProtocol
    private let userInfoStore: UserInfoStoreProtocol

    public init(
        fetchProfileUseCase: FetchMypageProfileUseCase,
        updateNicknameUseCase: UpdateMypageNicknameUseCase,
        updatePasswordUseCase: UpdateMypagePasswordUseCase,
        updateInterestsUseCase: UpdateMypageInterestsUseCase,
        updateIndustryUseCase: UpdateMypageIndustryUseCase,
        updatePhoneNumberUseCase: UpdateMypagePhoneNumberUseCase,
        authSMSUseCase: MypageAuthSMSUseCase,
        selectableItemStore: SelectableItemStoreProtocol = SelectableItemStore.shared,
        userInfoStore: UserInfoStoreProtocol = UserInfoStore.shared
    ) {
        self.fetchProfileUseCase = fetchProfileUseCase
        self.updateNicknameUseCase = updateNicknameUseCase
        self.updatePasswordUseCase = updatePasswordUseCase
        self.updateInterestsUseCase = updateInterestsUseCase
        self.updateIndustryUseCase = updateIndustryUseCase
        self.updatePhoneNumberUseCase = updatePhoneNumberUseCase
        self.authSMSUseCase = authSMSUseCase
        self.selectableItemStore = selectableItemStore
        self.userInfoStore = userInfoStore
    }

    func loadUserInfo() -> UserInfo? {
        userInfoStore.load()
    }

    public func fetchuserInfo() async {
        await performAsync(feature: "mypage", operation: "fetchUserInfo") {
            user = try await fetchProfileUseCase.execute()
        }
    }

    public func updateNickname(nickname: String) async -> Bool {
        guard !isNicknameUpdating else { return false }
        isNicknameUpdating = true
        defer { isNicknameUpdating = false }

        let result: Void? = await performAsync(feature: "mypage", operation: "updateNickname") {
            try await updateNicknameUseCase.execute(nickname)

            // UI 상태 업데이트
            if let currentUser = user {
                user = MypageUser(
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
        return result != nil
    }

    public func updateIndustry(id: Int) async -> Bool {
        guard !isIndustryUpdating else { return false }
        isIndustryUpdating = true
        defer { isIndustryUpdating = false }

        let result: Void? = await performAsync(feature: "mypage", operation: "updateIndustry") {
            try await updateIndustryUseCase.execute(id)

            // UI 상태 업데이트
            if let currentUser = user {
                user = MypageUser(
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
        return result != nil
    }

    public func updateInterests(ids: [Int]) async -> Bool {
        guard !isInterestUpdating else { return false }
        isInterestUpdating = true
        defer { isInterestUpdating = false }

        let result: Void? = await performAsync(feature: "mypage", operation: "updateInterests") {
            try await updateInterestsUseCase.execute(ids)

            // UI 상태 업데이트
            if let currentUser = user {
                let updatedInterests = ids.map { MypageInterest(id: $0, name: selectableItemStore.name(for: $0, in: .interest)) }
                user = MypageUser(
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
        return result != nil
    }

    public func updatePhoneNumber() async -> Bool {
        guard !isPhoneUpdating else { return false }
        // 인증번호 검증
        guard verifyCode() else {
            showError = true
            isPhoneUpdateSuccess = false
            return false
        }

        isPhoneUpdating = true
        defer { isPhoneUpdating = false }

        do {
            try await updatePhoneNumberUseCase.execute(phoneNumber)
            isPhoneUpdateSuccess = true
            showPhoneNumberSuccess = true
            return true
        } catch {
            isPhoneUpdateSuccess = false
            handleError(error, feature: "mypage", operation: "updatePhoneNumber")
            return false
        }
    }

    public func updatePassword() async -> Bool {
        guard !isPasswordUpdating else { return false }
        isPasswordUpdating = true
        defer { isPasswordUpdating = false }

        do {
            try await updatePasswordUseCase.execute(prevPassword: oldPassword, newPassword: newPassword)

            isPasswordUpdateSuccess = true
            oldPassword = ""
            newPassword = ""
            checkedPassword = ""
            showPasswordSuccess = true
            return true
        } catch {
            isPasswordUpdateSuccess = false
            passwordError = "현재 비밀번호가 일치하지 않습니다"
            handleError(error, feature: "mypage", operation: "updatePassword")
            return false
        }
    }

    public func sendVerificationCode() async {
        guard !isVerificationSending else { return }
        guard resendFailureCount < 3 else {
            isShowPopup = true
            return
        }

        isVerificationSending = true
        defer { isVerificationSending = false }
        defer { resendFailureCount += 1 }

        await performAsync(feature: "mypage", operation: "sendVerificationCode") {
            let response = try await authSMSUseCase.execute(phoneNumber: phoneNumber)
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
        return NewdokInputValidator.validatePassword(newPassword) == nil
    }

    public var isNewPasswordConfirmed: Bool {
        return newPassword == checkedPassword
    }

    public var isPasswordValid: Bool {
        return isOldPasswordValid && isNewPasswordValid && isNewPasswordConfirmed
    }

    func industryName(for id: Int) -> String {
        selectableItemStore.name(for: id, in: .industry)
    }

    func interestName(for id: Int) -> String {
        selectableItemStore.name(for: id, in: .interest)
    }

    var industries: [SelectableItem] {
        selectableItemStore.list(for: .industry)
    }

    var interests: [SelectableItem] {
        selectableItemStore.list(for: .interest)
    }

    public var oldPasswordError: String? {
        if oldPassword.isEmpty || isOldPasswordValid { return nil }
        return "8자 이상의 비밀번호를 입력해주세요."
    }

    public var newPasswordError: String? {
        if newPassword.isEmpty || isNewPasswordValid { return nil }
        return NewdokInputValidator.validatePassword(newPassword)?.message
    }

    public var confirmPasswordError: String? {
        if checkedPassword.isEmpty || isNewPasswordConfirmed { return nil }
        return "비밀번호가 일치하지 않습니다."
    }
}
