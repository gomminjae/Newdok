//
//  PasswordUpdateViewModel.swift
//  Mypage
//
//  Created by 권민재 on 5/20/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import MypageDomain
import Shared
import FoundationKit
import Observation

@Observable
@MainActor
public final class PasswordUpdateViewModel: ErrorHandling {
    public var oldPassword: String = ""
    public var newPassword: String = ""
    public var checkedPassword: String = ""
    public var isPasswordUpdating: Bool = false
    public var isPasswordUpdateSuccess: Bool = false
    public var passwordError: String?
    public var showPasswordSuccess: Bool = false
    public var currentError: AppError?

    private let updatePasswordUseCase: UpdateMypagePasswordUseCase

    public init(updatePasswordUseCase: UpdateMypagePasswordUseCase) {
        self.updatePasswordUseCase = updatePasswordUseCase
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
        } catch MypageProfileError.userNotFound {
            isPasswordUpdateSuccess = false
            passwordError = nil
            currentError = .userMessage("사용자 정보를 찾을 수 없습니다")
            return false
        } catch {
            isPasswordUpdateSuccess = false
            passwordError = "현재 비밀번호가 일치하지 않습니다"
            handleError(error, feature: "mypage", operation: "updatePassword")
            return false
        }
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
