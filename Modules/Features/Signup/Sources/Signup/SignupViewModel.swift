//
//  SignupViewModel.swift
//  Newdok
//
//  Created by 권민재 on 3/6/25.
//

import Foundation
import Domain

@MainActor
final public class SignupViewModel: ObservableObject {

    private let userUseCase: UserUseCase

    // MARK: - Form
    @Published public var phoneNumber: String = ""
    @Published public var enteredVerificationCode: String = ""
    private var verificationCode: String = ""
    
    //MARK: - id
    @Published public var loginID: String = ""
    @Published public var isIDAvailable: Bool? = nil

    // MARK: - State
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var userList: [SimpleUser] = []
    @Published public var isShowUserList = false
    @Published public var isRequestSent = false
    @Published public var isTimerActive = false
    @Published public var timerRemaining = 180
    @Published public var showAlreadyRegisteredAlert = false
    @Published public var showError = false
    
    
    @Published public var emails: [String] = []
    @Published public var isShowPopup: Bool = false

    private var timer: Timer?
    
    
    //MARK: password
    @Published public var password: String = ""
    @Published public var checkedPassword: String = ""
    
    //MARK: profile
    @Published public var nickname: String = ""
    @Published public var birthYear: String = ""
    @Published public var gender: String = ""
    
    
    @Published public var user: User?
    
    
    
    
    

    public init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
    }

    public func sendVerificationCode() {
        Task {
            do {
                isLoading = true
                userList = []
                isShowUserList = false
                showError = false
                errorMessage = nil
                
                let rawPhoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")

                let users = try await userUseCase.checkPhoneNumber(rawPhoneNumber)
                if !users.isEmpty {
                    userList = users
                    isShowUserList = true
                    showAlreadyRegisteredAlert = true
                    return
                }
                
                let result = try await userUseCase.authSMS(phoneNumber: rawPhoneNumber)
                verificationCode = String(result.code)
                isRequestSent = true
                startTimer()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    public func verifyCode() -> Bool {
        if enteredVerificationCode == verificationCode {
            return true
        } else {
            showError = true
            return false
        }
    }

    public func startTimer() {
        timer?.invalidate()
        isTimerActive = true
        timerRemaining = 180

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { return t.invalidate() }

            Task { @MainActor in
                if self.timerRemaining > 0 {
                    self.timerRemaining -= 1
                } else {
                    t.invalidate()
                    self.isTimerActive = false
                }
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
    
    public func checkIDDup() {
        isIDAvailable = nil
        Task {
            do {
                let result = try await userUseCase.checkIDDup(loginID)
                
                switch result {
                case .exists:
                    isIDAvailable = false
                case .notFound:
                    isIDAvailable = true
                }
            } catch {
                isIDAvailable = nil
            }
        }
    }
    
    public func validateNickname() -> NickNameValidationError? {
        if nickname.count > 12 {
            return .tooLong
        }
        let specialCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()_+-=~`[]{}|:;\"'<>,.?/")
        if nickname.rangeOfCharacter(from: specialCharacterSet) != nil {
            return .containsSpecialCharacters
        }
        return nil
    }
    
    public func signIn() {
        Task {
            do {
                let result = try await userUseCase.signup(loginId: loginID, password: password, phoneNumber: phoneNumber, nickname: nickname, birthYear: birthYear, gender: gender)
                user = result.user
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    
    
}
