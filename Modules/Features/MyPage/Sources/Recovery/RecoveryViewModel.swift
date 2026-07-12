//
//  RecoveryViewModel.swift
//  Recovery
//
//  Created by 권민재 on 6/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import MypageDomain
import Shared
import Observation

@Observable
@MainActor
public final class RecoveryViewModel: ErrorHandling {
    private let checkPhoneNumberUseCase: CheckMypagePhoneNumberUseCase
    private let checkIDDupUseCase: CheckMypageIDDupUseCase
    private let authSMSUseCase: MypageAuthSMSUseCase
    private let resetPasswordUseCase: ResetMypagePasswordUseCase

    // 화면 흐름 그대로 유지 (0: 아이디, 1: 인증, 2: 비번입력, 3: 완료)
    var passwordRecoveryStep: Int = 0

    var currentPage = 0

    // 아이디/번호
    public var users: [MypageSimpleUser] = []
    public var phoneNumber: String = ""
    public var loginID: String = ""

    // 인증
    var recoveryId: String = ""
    var recoveryPhone: String = ""
    var recoveryCode: String = ""
    var recoveryCodeSent: Bool = false
    var recoveryCodeVerified: Bool? // nil 미시도, true 성공, false 실패
    var recoveryErrorMessage: String?

    // 새 비밀번호
    var newPassword: String = ""
    var newPasswordCheck: String = ""
    var passwordResetSuccess: Bool?

    // 팝업(제한/타임아웃)
    public var isShowPopup: Bool = false

    // 내부 상태
    public private(set) var resendCount: Int = 0
    private let maxResends = 3
    private var sentCode: String = ""
    public var currentError: AppError?

    // 타이머
    public var isRequestSent: Bool = false
    public var isTimerActive: Bool = false
    public var timerRemaining: Int = 180
    private var timerTask: Task<Void, Never>?

    public init(
        checkPhoneNumberUseCase: CheckMypagePhoneNumberUseCase,
        checkIDDupUseCase: CheckMypageIDDupUseCase,
        authSMSUseCase: MypageAuthSMSUseCase,
        resetPasswordUseCase: ResetMypagePasswordUseCase
    ) {
        self.checkPhoneNumberUseCase = checkPhoneNumberUseCase
        self.checkIDDupUseCase = checkIDDupUseCase
        self.authSMSUseCase = authSMSUseCase
        self.resetPasswordUseCase = resetPasswordUseCase
    }

    // MARK: - 아이디 찾기
    func findMyIds() async {
        await performAsync(feature: "recovery", operation: "findMyIds") {
            let response = try await checkPhoneNumberUseCase.execute(phoneNumber)
            users = response
        }
    }

    // MARK: - 아이디 존재 확인 (기존 시그니처 유지)
    public func checkIdExists() async -> MypageSimpleUser? {
        do {
            let result = try await checkIDDupUseCase.execute(recoveryId)
            switch result {
            case .exists(let user): return user
            case .notFound:        return nil
            }
        } catch {
            handleError(error, feature: "recovery", operation: "checkIdExists")
            return nil
        }
    }

    // MARK: - 인증코드 전송 (초기/재전송 공용)
    public func sendRecoveryCode(isResend: Bool = false) async {
        // 4번째 재전송 시도에서 팝업 (초기 1회 + 재전송 3회까지 허용)
        if isResend, resendCount >= maxResends {
            isShowPopup = true
            return
        }
        do {
            let response = try await authSMSUseCase.execute(phoneNumber: recoveryPhone)
            sentCode = String(response.code)
            recoveryCode = ""
            recoveryCodeSent = true
            recoveryErrorMessage = nil

            if isResend { resendCount += 1 }

            // 타이머 리셋
            isRequestSent = true
            timerRemaining = 180
            startTimer()
        } catch {
            recoveryErrorMessage = "인증번호 발송에 실패했습니다."
            handleError(error, feature: "recovery", operation: "sendRecoveryCode")
        }
    }

    // MARK: - 인증 확인
    func verifyRecoveryCode() {
        guard isRequestSent, timerRemaining > 0 else {
            recoveryCodeVerified = false
            return
        }
        if recoveryCode == sentCode {
            recoveryCodeVerified = true
            stopTimer()
            // 인증 성공 시 제한 초기화
            resendCount = 0
            isShowPopup = false
        } else {
            recoveryCodeVerified = false
        }
    }

    // MARK: - 비밀번호 재설정
    func resetPassword() async {
        do {
            try await resetPasswordUseCase.execute(loginId: recoveryId, newPassword: newPassword)
            passwordResetSuccess = true
        } catch {
            passwordResetSuccess = false
            handleError(error, feature: "recovery", operation: "resetPassword")
        }
    }

    // MARK: - 팝업 닫기 & 처음부터
    public func resetVerificationStateAndRestart() {
        stopTimer()
        isShowPopup = false
        isRequestSent = false
        timerRemaining = 180
        resendCount = 0
        sentCode = ""
        recoveryCode = ""
        recoveryCodeVerified = nil
        recoveryErrorMessage = nil
        // 이전 단계 입력값 초기화
        recoveryId = ""
        recoveryPhone = ""
        // 처음 단계로
        passwordRecoveryStep = 0
    }

    // MARK: - Timer
    private func startTimer() {
        stopTimer()
        isTimerActive = true
        timerTask = Task { [weak self] in
            while !Task.isCancelled, let self, self.timerRemaining > 0 {
                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    break
                }
                guard !Task.isCancelled else { break }
                self.timerRemaining -= 1
            }
            guard let self, self.timerRemaining <= 0 else { return }
            self.isTimerActive = false
            // 3회 모두 사용한 상태에서 만료되면 팝업
            if self.resendCount >= self.maxResends {
                self.isShowPopup = true
            }
        }
    }

    private func stopTimer() {
        isTimerActive = false
        timerTask?.cancel()
        timerTask = nil
    }
}
