//
//  RecoveryViewModel.swift
//  Recovery
//
//  Created by 권민재 on 6/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import Domain


@MainActor
public class RecoveryViewModel: ObservableObject {
    
    private let userUseCase: UserUseCase
    
    @Published var currentPage: Int = 0
    
    @Published public var users: [SimpleUser] = []
    
    @Published public var phoneNumber: String = ""
    
    
    @Published public var password: String = ""
    @Published public var checkPassword: String = ""
    
    @Published public var loginID: String = ""
    @Published var passwordRecoveryStep: Int = 0 // 0: 아이디, 1: 인증, 2: 비번입력, 3: 완료
    @Published var recoveryId: String = ""
    @Published var recoveryPhone: String = ""
    @Published var recoveryCode: String = ""
    @Published var recoveryCodeSent: Bool = false
    @Published var recoveryCodeVerified: Bool? = nil // nil: 미시도, true: 성공, false: 실패
    @Published var newPassword: String = ""
    @Published var newPasswordCheck: String = ""
    @Published var passwordResetSuccess: Bool? = nil
    @Published var recoveryErrorMessage: String? = nil
    
    // 인증번호 저장용
    @Published var sentCode: String = ""
    
    
    public init(useCase: UserUseCase) {
        self.userUseCase = useCase
    }
    
    
    
    func findMyIds() async {
        do {
            let response = try await userUseCase.checkPhoneNumber(phoneNumber)
            users = response
        } catch {
            print("핸드폰 번호 조회 에러")
        }
    }
    
    
    func checkIdExists() async -> Bool {
        do {
            let result = try await userUseCase.checkIDDup(recoveryId)
            switch result {
            case .exists(_):
                return true
            case .notFound:
                return false
            }
        } catch {
            print("아이디 확인 에러", error)
            return false
        }
    }
    
    public func checkIdExists() async -> SimpleUser? {
        do {
            let result = try await userUseCase.checkIDDup(recoveryId)
            switch result {
            case .exists(let user):
                return user
            case .notFound:
                return nil
            }
        } catch {
            return nil
        }
    }
    func sendRecoveryCode() async {
        do {
            let response = try await userUseCase.authSMS(phoneNumber: recoveryPhone)
            recoveryCodeSent = true
            recoveryErrorMessage = nil
            sentCode = String(response.code)
        } catch {
            recoveryErrorMessage = "인증번호 발송에 실패했습니다."
        }
    }
    func verifyRecoveryCode() async {
        if recoveryCode == sentCode {
            recoveryCodeVerified = true
        } else {
            recoveryCodeVerified = false
        }
    }
    func resetPassword() async {
        do {
            try await userUseCase.updatePassword(loginId: recoveryId, prevPassword: "", newPassword: newPassword)
            passwordResetSuccess = true
        } catch {
            passwordResetSuccess = false
        }
    }
    
}
