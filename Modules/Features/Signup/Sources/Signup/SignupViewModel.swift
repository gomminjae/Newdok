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
    
    @Published var currentStep: SignupStep = .enterProfile

    // MARK: - Form
    @Published public var phoneNumber: String = ""
    @Published public var enteredVerificationCode: String = ""
    private var verificationCode: String = ""
    @Published public var resendFailureCount: Int = 0
    
    
    
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
    
    public func goToNextStep() {
        if let next = SignupStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }
    
    public func goToPreviousStep() {
        if let prev = SignupStep(rawValue: currentStep.rawValue - 1) {
            currentStep = prev
        }
    }
    
    
    

    public func sendVerificationCode() {
        guard resendFailureCount < 3 else {
            isShowPopup = true
            return
        }
        Task {
            do {
                isLoading = true
                userList = []
                isShowUserList = false
                showError = false
                errorMessage = nil
                enteredVerificationCode = ""
                
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
    
    public func checkIDDup() {
        isIDAvailable = nil
        Task { @MainActor in 
            do {
                let result = try await userUseCase.checkIDDup(loginID)
                
                switch result {
                case .exists:
                    isIDAvailable = false
                case .notFound:
                    isIDAvailable = true
                }
                print("Helloooo: \(isIDAvailable)")
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
