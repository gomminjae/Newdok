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
    public var isInterestUpdating: Bool = false

    private let useCase: MypageUserUseCase
    private let profileUseCase: MypageProfileUseCase
    private let selectableItemStore: SelectableItemStoreProtocol
    private let userInfoStore: UserInfoStoreProtocol

    public init(
        useCase: MypageUserUseCase,
        profileUseCase: MypageProfileUseCase,
        selectableItemStore: SelectableItemStoreProtocol = SelectableItemStore.shared,
        userInfoStore: UserInfoStoreProtocol = UserInfoStore.shared
    ) {
        self.selectableItemStore = selectableItemStore
        self.userInfoStore = userInfoStore
        self.useCase = useCase
        self.profileUseCase = profileUseCase
    }

    func loadUserInfo() -> UserInfo? {
        userInfoStore.load()
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
    }

    public func updateIndustry(id: Int) async {
        await performAsync(feature: "mypage", operation: "updateIndustry") {
            try await profileUseCase.updateIndustry(id)

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
    }

    public func updateInterests(ids: [Int]) async {
        isInterestUpdating = true
        await performAsync(feature: "mypage", operation: "updateInterests") {
            try await profileUseCase.updateInterests(ids)

            // UI 상태 업데이트
            if let currentUser = user {
                let updatedInterests = ids.map { MypageInterest(id: $0, name: selectableItemStore.name(for: $0, in: .interest) ?? "") }
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
        return "8자 이상의 비밀번호를 입력해주세요."
    }

    public var confirmPasswordError: String? {
        if checkedPassword.isEmpty || isNewPasswordConfirmed { return nil }
        return "비밀번호가 일치하지 않습니다."
    }
}
