//
//  SignupViewModelResult.swift
//  Signup
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation
import Domain
import SwiftUI
import Shared
import Combine

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

public enum SignupStep: Int, CaseIterable {
    case agreeTerms = 0
    case phoneVerification = 1
    case idPassword = 2
    case profileInput = 3
    case investigate = 4
    case completed = 5
}

@MainActor
final public class SignupViewModelResult: ObservableObject {

    // MARK: - Dependencies
    private let userUseCase: UserUseCaseResult
    
    // MARK: - Step Management
    @Published var currentStep: SignupStep = .agreeTerms
    
    // MARK: - Loading & Error States
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    
    // MARK: - Phone Verification
    @Published public var phoneNumber: String = ""
    @Published public var enteredVerificationCode: String = ""
    @Published public var resendFailureCount: Int = 0
    @Published public var userList: [SimpleUser] = []
    @Published public var isShowUserList = false
    @Published public var isRequestSent = false
    @Published public var isTimerActive = false
    @Published public var timerRemaining = 180
    @Published public var showAlreadyRegisteredAlert = false
    @Published public var showError = false
    @Published public var isShowPopup: Bool = false
    @Published public var emails: [String] = []
    
    private var verificationCode: String = ""
    private var timer: Timer?
    
    // MARK: - ID & Password
    @Published public var loginID: String = "" {
        didSet {
            isIDAvailable = nil
            validateLoginID()
        }
    }
    @Published public var isIDAvailable: Bool? = nil
    @Published public var loginIDValidation: AppResult<String>?
    @Published public var password: String = ""
    @Published public var checkedPassword: String = ""
    @Published public var passwordValidation: AppResult<String>?
    
    // MARK: - Profile
    @Published public var nickname: String = ""
    @Published public var birthYear: String = ""
    @Published public var gender: String = ""
    @Published public var nicknameValidation: AppResult<String>?
    @Published public var user: User?
    
    // MARK: - Investigation
    @Published public var myIndustry: String = ""
    @Published public var selectedInterests: Set<String> = []
    @Published public var recommendedPost: [RecommendedBrand] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var idValidationError: IDValidationError? {
        guard !loginID.isEmpty else { return nil }
        return validateID()
    }

    var isIDCheckEnabled: Bool {
        return validateID() == nil
    }

    var isIDErrorState: Bool {
        guard !loginID.isEmpty else { return false }
        
        if isIDAvailable == false {
            return true
        }
        
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
    
    // MARK: - Initialization
    public init(userUseCase: UserUseCaseResult) {
        self.userUseCase = userUseCase
        setupValidation()
    }
    
    // MARK: - Validation Setup
    private func setupValidation() {
        // Nickname 실시간 검증
        $nickname
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] nickname in
                self?.validateNickname(nickname)
            }
            .store(in: &cancellables)
        
        // Password 실시간 검증
        $password
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] password in
                self?.validatePassword(password)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Step Navigation
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
    
    // MARK: - Phone Verification
    public func sendVerificationCode(skipCheck: Bool = false) async -> AppResult<Void> {
        guard resendFailureCount < 3 else {
            await MainActor.run {
                isShowPopup = true
            }
            return .failure(.business(.operationNotAllowed))
        }
        
        await MainActor.run {
            isLoading = true
            userList = []
            isShowUserList = false
            errorMessage = nil
            enteredVerificationCode = ""
            showError = false
            timerRemaining = 180
        }
        
        // 전화번호 중복 확인 (skipCheck가 false인 경우)
        if !skipCheck {
            let checkResult = await userUseCase.checkPhoneNumber(phoneNumber)
            
            if case .success(let users) = checkResult, !users.isEmpty {
                await MainActor.run {
                    userList = users
                    isShowUserList = true
                    showAlreadyRegisteredAlert = true
                    isLoading = false
                }
                return .failure(.business(.operationNotAllowed))
            }
            
            if case .failure(let error) = checkResult {
                await MainActor.run {
                    isLoading = false
                }
                await handleError(error, context: "전화번호 확인")
                return checkResult.map { _ in () }
            }
        }
        
        // SMS 인증번호 발송
        let smsResult = await userUseCase.authSMS(phoneNumber: phoneNumber)
        
        await smsResult
            .onSuccess { [weak self] smsResponse in
                await self?.handleSMSSuccess(smsResponse)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "인증번호 발송")
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return smsResult.map { _ in () }
    }
    
    public func verifyCode() -> Bool {
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
    
    // MARK: - ID Validation & Check
    private func validateLoginID() {
        guard !loginID.isEmpty else {
            loginIDValidation = nil
            return
        }
        
        loginIDValidation = userUseCase.validateLoginId(loginID)
    }
    
    private func validatePassword(_ password: String) {
        guard !password.isEmpty else {
            passwordValidation = nil
            return
        }
        
        if password.count < 6 {
            passwordValidation = .failure(.validation(.tooShort("비밀번호")))
        } else if password.count > 20 {
            passwordValidation = .failure(.validation(.tooLong("비밀번호")))
        } else {
            passwordValidation = .success(password)
        }
    }
    
    private func validateNickname(_ nickname: String) {
        guard !nickname.isEmpty else {
            nicknameValidation = nil
            return
        }
        
        nicknameValidation = userUseCase.validateNickname(nickname)
    }
    
    public func validateID() -> IDValidationError? {
        let id = loginID
        let isValidLength = AppConstants.Validation.idLengthRange.contains(id.count)
        let hasLetter = id.rangeOfCharacter(from: .letters) != nil
        let hasNumber = id.rangeOfCharacter(from: .decimalDigits) != nil
        let isAlphanumeric = hasLetter && hasNumber
        
        let allowedCharset = CharacterSet.alphanumerics
        let containsOnlyAllowed = id.rangeOfCharacter(from: allowedCharset.inverted) == nil
        
        if !isValidLength && (!isAlphanumeric || !containsOnlyAllowed) {
            return .invalidLengthAndCombination
        }
        
        if !isValidLength {
            return .invalidLength
        }
        
        if !isAlphanumeric || !containsOnlyAllowed {
            return .invalidCombination
        }
        
        return nil
    }
    
    public func checkIDDup() async -> AppResult<Bool> {
        guard validateID() == nil else {
            await MainActor.run {
                isIDAvailable = nil
            }
            return .failure(.validation(.invalidFormat("아이디")))
        }
        
        await MainActor.run {
            isIDAvailable = nil
            isLoading = true
        }
        
        let result = await userUseCase.checkIDDup(loginID)
        
        await result
            .onSuccess { [weak self] checkResult in
                await self?.handleIDCheckSuccess(checkResult)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "아이디 중복 확인")
                await MainActor.run {
                    self?.isIDAvailable = nil
                }
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result.map { checkResult in
            switch checkResult {
            case .exists:
                return false // 중복됨
            case .notFound:
                return true // 사용 가능
            }
        }
    }
    
    // MARK: - Investigation
    public func toggleInterest(_ key: String) {
        if selectedInterests.contains(key) {
            selectedInterests.remove(key)
        } else {
            selectedInterests.insert(key)
        }
    }
    
    public func submitInterests() async -> AppResult<[RecommendedBrand]> {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await userUseCase.preInvestigate(
            industryId: myIndustry,
            interestIds: Array(selectedInterests)
        )
        
        await result
            .onSuccess { [weak self] brands in
                await self?.handleInvestigationSuccess(brands)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "사전 조사")
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result
    }
    
    // MARK: - Signup
    public func signup() async -> AppResult<(User, String)> {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await userUseCase.signup(
            loginId: loginID,
            password: password,
            phoneNumber: phoneNumber,
            nickname: nickname,
            birthYear: birthYear,
            gender: gender
        )
        
        await result
            .onSuccess { [weak self] signupResponse in
                await self?.handleSignupSuccess(signupResponse)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "회원가입")
            }
        
        await MainActor.run {
            isLoading = false
        }
        
        return result.map { signupResponse in
            (signupResponse.user, signupResponse.accessToken)
        }
    }
    
    // MARK: - Success Handlers
    @MainActor
    private func handleSMSSuccess(_ smsResponse: SMSResponse) async {
        self.verificationCode = String(smsResponse.code)
        self.isRequestSent = true
        startTimer()
    }
    
    @MainActor
    private func handleIDCheckSuccess(_ checkResult: CheckResult<SimpleUser>) async {
        switch checkResult {
        case .exists:
            self.isIDAvailable = false
        case .notFound:
            self.isIDAvailable = true
        }
    }
    
    @MainActor
    private func handleInvestigationSuccess(_ brands: [RecommendedBrand]) async {
        self.recommendedPost = brands
        goToNextStep()
    }
    
    @MainActor
    private func handleSignupSuccess(_ signupResponse: SignupResponse) async {
        TokenStorage.accessToken = signupResponse.accessToken
        self.user = signupResponse.user
        goToNextStep()
    }
    
    // MARK: - Error Handler
    @MainActor
    private func handleError(_ error: AppError, context: String) async {
        switch error {
        case .network(let networkError):
            switch networkError {
            case .networkUnavailable:
                self.errorMessage = "네트워크 연결을 확인해주세요"
            case .timeout:
                self.errorMessage = "요청 시간이 초과되었습니다"
            case .serverError(let statusCode, let message):
                if statusCode == 400 {
                    if context == "아이디 중복 확인" {
                        self.errorMessage = "이미 사용중인 아이디입니다"
                    } else if context == "회원가입" {
                        self.errorMessage = message ?? "회원가입에 실패했습니다"
                    } else {
                        self.errorMessage = message ?? "잘못된 요청입니다"
                    }
                } else {
                    self.errorMessage = "서버 오류가 발생했습니다"
                }
            case .unknown(let message):
                self.errorMessage = message
            }
        case .validation(let validationError):
            switch validationError {
            case .emptyField(let field):
                self.errorMessage = "\(field)을(를) 입력해주세요"
            case .invalidFormat(let field):
                self.errorMessage = "\(field) 형식이 올바르지 않습니다"
            case .tooShort(let field):
                self.errorMessage = "\(field)이(가) 너무 짧습니다"
            case .tooLong(let field):
                self.errorMessage = "\(field)이(가) 너무 깁니다"
            }
        case .business(let businessError):
            switch businessError {
            case .userNotFound:
                self.errorMessage = "사용자를 찾을 수 없습니다"
            case .invalidCredentials:
                self.errorMessage = "인증 정보가 올바르지 않습니다"
            case .operationNotAllowed:
                if context == "인증번호 발송" {
                    self.errorMessage = "인증번호 재전송 횟수를 초과했습니다"
                } else if context == "전화번호 확인" {
                    self.errorMessage = "이미 등록된 전화번호입니다"
                } else {
                    self.errorMessage = "허용되지 않은 작업입니다"
                }
            case .dataNotFound:
                self.errorMessage = "데이터를 찾을 수 없습니다"
            case .accountLocked:
                self.errorMessage = "계정이 잠겨있습니다"
            }
        case .unknown(let message):
            self.errorMessage = message.isEmpty ? "\(context) 처리 중 오류가 발생했습니다" : message
        }
        
        print("❌ \(context) 실패: \(error)")
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        stopTimer()
        isTimerActive = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
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
        isTimerActive = false
    }
    
    deinit {
        stopTimer()
    }
} 