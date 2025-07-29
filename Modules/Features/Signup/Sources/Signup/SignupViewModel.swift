//
//  SignupViewModel.swift
//  Newdok
//
//  Created by 권민재 on 3/6/25.
//

import Foundation
import Domain
import SwiftUI
import Shared

public protocol TimerProtocol {
    func invalidate()
}

public protocol TimerServiceProtocol {
    func scheduleTimer(withTimeInterval: TimeInterval, repeats: Bool, block: @escaping () -> Void) -> TimerProtocol
}

public struct DefaultTimerService: TimerServiceProtocol {
    public init() {}
    
    public func scheduleTimer(withTimeInterval: TimeInterval, repeats: Bool, block: @escaping () -> Void) -> TimerProtocol {
        let timer = Timer.scheduledTimer(withTimeInterval: withTimeInterval, repeats: repeats) { _ in
            block()
        }
        return DefaultTimer(timer: timer)
    }
}

public struct DefaultTimer: TimerProtocol {
    private let timer: Timer
    
    public init(timer: Timer) {
        self.timer = timer
    }
    
    public func invalidate() {
        timer.invalidate()
    }
}
public enum IDValidationError: Error {
    case invalidLengthAndCombination
    case invalidLength
    case invalidCombination

    var message: String {
        switch self {
        case .invalidLengthAndCombination:
            return "6~12자, 영문/숫자 조합으로 입력해주세요."
        case .invalidLength:
            return "6~12자 이내로 입력해주세요."
        case .invalidCombination:
            return "영문/숫자 조합으로 구성해주세요."
        }
    }
}

public enum NickNameValidationError: Error {
    case tooLong
    case containsSpecialCharacters
    
    var message: String {
        switch self {
        case .tooLong:
            return "닉네임은 최대 12자까지 입력할 수 있습니다."
        case .containsSpecialCharacters:
            return "특수문자는 사용할 수 없습니다."
        }
    }
}

public enum NicknameValidationError: Error {
    case invalidLength
    case containsInvalidCharacters
    
    var message: String {
        switch self {
        case .invalidLength:
            return "1자 이상 12자 이하로 입력해주세요."
        case .containsInvalidCharacters:
            return "특수문자와 공백은 사용할 수 없습니다."
        }
    }
}

@MainActor
final public class SignupViewModel: ObservableObject {

    public let userUseCase: UserUseCase
    public let newsletterUseCase: NewsletterUseCase
    private let timerService: TimerServiceProtocol
    
    @Published var currentStep: SignupStep = .phoneVerification

    @Published public var phoneNumber: String = ""
    @Published public var enteredVerificationCode: String = ""
    private var verificationCode: String = ""
    @Published public var resendFailureCount: Int = 0
    
    @Published public var loginID: String = "" {
        didSet {
            isIDAvailable = nil
        }
    }
    @Published public var isIDAvailable: Bool? = nil
    
    var idValidationError: IDValidationError? {
        guard !loginID.isEmpty else { return nil }
        return validateID()
    }

    var isIDCheckEnabled: Bool {
        return validateID() == nil
    }

    var isIDErrorState: Bool {
        // 0. 입력이 아예 없으면 에러 표시 안 함
        guard !loginID.isEmpty else { return false }

        // 1. 중복 확인 실패
        if isIDAvailable == false {
            return true
        }

        // 2. 중복 확인을 안 했고, 형식 에러가 있는 경우
        if isIDAvailable == nil, validateID() != nil {
            return true
        }

        return false
    }

    var idValidationMessage: (text: String, color: Color)? {
        if let available = isIDAvailable {
            return (
                text: available ? "사용 가능한 아이디입니다" : "이미 사용중인 아이디입니다",
                color: available ? Color(hex: "#2866D3") : Color(hex: "#E32727")
            )
        } else if let error = idValidationError {
            return (
                text: error.message,
                color: Color(hex: "#E32727")
            )
        } else {
            return nil
        }
    }
    
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

    private var timer: TimerProtocol?
    
    @Published public var password: String = ""
    @Published public var checkedPassword: String = ""
    
    @Published public var nickname: String = ""
    @Published public var birthYear: String = ""
    @Published public var gender: String = ""
    
    @Published public var user: User?
    
    @Published public var myIndustry: String = ""
    @Published public var selectedInterests: Set<String> = []
    @Published public var recommendedPost: [RecommendedBrand] = []
    
    public init(
        userUseCase: UserUseCase, 
        newsletterUseCase: NewsletterUseCase,
        timerService: TimerServiceProtocol = DefaultTimerService()
    ) {
        self.userUseCase = userUseCase
        self.newsletterUseCase = newsletterUseCase
        self.timerService = timerService
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
    
    public func sendVerificationCode(skipCheck: Bool = false) {
        guard resendFailureCount < 3 else {
            isShowPopup = true
            return
        }
        
        Task {
            do {
                isLoading = true
                userList = []
                isShowUserList = false
                errorMessage = nil
                enteredVerificationCode = ""
                showError = false
                timerRemaining = 180

                if !skipCheck {
                    let users = try await userUseCase.checkPhoneNumber(phoneNumber)
                    if !users.isEmpty {
                        userList = users
                        isShowUserList = true
                        showAlreadyRegisteredAlert = true
                        isLoading = false
                        return
                    }
                }

                let result = try await userUseCase.authSMS(phoneNumber: phoneNumber)
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
        timer = timerService.scheduleTimer(withTimeInterval: 1.0, repeats: true) { [weak self] in
            guard let self = self else { return }
            Task { @MainActor in
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
    
    public func validateID() -> IDValidationError? {
        let id = loginID
        let isValidLength = (6...12).contains(id.count)
        let hasLetter = id.rangeOfCharacter(from: .letters) != nil
        let hasNumber = id.rangeOfCharacter(from: .decimalDigits) != nil
        let isAlphanumeric = hasLetter && hasNumber

        // 특수문자 제거 (영문+숫자만 허용)
        let allowedCharset = CharacterSet.alphanumerics
        let containsOnlyAllowed = id.rangeOfCharacter(from: allowedCharset.inverted) == nil

        // case 1: 길이 + 조합 둘 다 틀림
        if !isValidLength && (!isAlphanumeric || !containsOnlyAllowed) {
            return .invalidLengthAndCombination
        }

        // case 2: 길이만 틀림
        if !isValidLength {
            return .invalidLength
        }

        // case 3: 조합만 틀림
        if !isAlphanumeric || !containsOnlyAllowed {
            return .invalidCombination
        }

        return nil
    }
    
    public func checkIDDup() {
        guard validateID() == nil else {
            isIDAvailable = nil
            return
        }

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
            } catch {
                isIDAvailable = nil
            }
        }
    }
    
    func toggleInterest(_ key: String) {
        if selectedInterests.contains(key) {
            selectedInterests.remove(key)
        } else {
            selectedInterests.insert(key)
        }
    }
    
    func submitInterests() {
        Task {
            do {
                let result = try await userUseCase.preInvestigate(industryId: myIndustry, interestIds: Array(selectedInterests))
                recommendedPost = result
                goToNextStep()
            } catch {
                print("전송 실패: \(error)")
            }
        }
    }
    
    func signup() {
        Task {
            do {
                let result = try await userUseCase.signup(loginId: loginID, password: password, phoneNumber: phoneNumber, nickname: nickname, birthYear: birthYear, gender: gender)
                TokenStorage.accessToken = result.accessToken
                user = result.user
                goToNextStep()
            } catch {
                print("회원가입 실패: \(error)")
            }
        }
    }
}
