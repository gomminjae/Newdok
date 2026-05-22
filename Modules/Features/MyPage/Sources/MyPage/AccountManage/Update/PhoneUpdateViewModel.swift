//
//  PhoneUpdateViewModel.swift
//  Mypage
//
//  Created by 권민재 on 5/20/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import MypageDomain
import Shared
import Observation

@Observable
@MainActor
public final class PhoneUpdateViewModel: ErrorHandling {
    var phoneNumber: String = ""
    public var enteredVerificationCode: String = ""
    private var verificationCode: String = ""
    public var isRequestSent = false
    public var isTimerActive = false
    public var timerRemaining = 180
    public var resendFailureCount: Int = 0
    public var isShowPopup: Bool = false
    public var isPhoneUpdating: Bool = false
    public var isPhoneUpdateSuccess: Bool = false
    public var showPhoneNumberSuccess: Bool = false
    public var showAlreadyRegisteredAlert = false
    public var showError = false
    public var isVerificationSending: Bool = false
    private var timerTask: Task<Void, Never>?
    public var currentError: AppError?

    private let authSMSUseCase: MypageAuthSMSUseCase
    private let updatePhoneNumberUseCase: UpdateMypagePhoneNumberUseCase

    public init(
        authSMSUseCase: MypageAuthSMSUseCase,
        updatePhoneNumberUseCase: UpdateMypagePhoneNumberUseCase
    ) {
        self.authSMSUseCase = authSMSUseCase
        self.updatePhoneNumberUseCase = updatePhoneNumberUseCase
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
}
