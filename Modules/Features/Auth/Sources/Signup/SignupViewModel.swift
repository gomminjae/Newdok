import Foundation
import AuthDomain
import SwiftUI
import Shared
import Observation

@Observable
@MainActor
public final class SignupViewModel: ErrorHandling {
    private let authRepository: AuthRepository
    private let signupUseCase: SignupUseCase

    var currentStep: SignupStep = .phoneVerification

    // MARK: - Form
    public var phoneNumber: String = ""

    var isPhoneNumberValid: Bool {
        SignupFormatStyle.validatePhoneNumber(phoneNumber) == nil
    }
    public var enteredVerificationCode: String = ""
    private var verificationCode: String = ""
    public var resendFailureCount: Int = 0

    // MARK: - ID
    public var loginID: String = "" {
        didSet {
            if oldValue != loginID {
                isIDAvailable = nil
            }
        }
    }
    public var isIDAvailable: Bool?

    var idValidationError: IDValidationError? {
        guard !loginID.isEmpty else { return nil }
        return SignupFormatStyle.validateID(loginID)
    }

    var isIDCheckEnabled: Bool { SignupFormatStyle.validateID(loginID) == nil }

    var isIDErrorState: Bool {
        guard !loginID.isEmpty else { return false }
        if isIDAvailable == false { return true }
        if isIDAvailable == nil, SignupFormatStyle.validateID(loginID) != nil { return true }
        return false
    }

    var idValidationMessage: (text: String, color: Color)? {
        if let available = isIDAvailable {
            return (available ? "사용 가능한 아이디입니다" : "이미 사용중인 아이디입니다",
                    available ? Color.primaryNormal : Color.errorNormal)
        } else if let error = idValidationError {
            return (error.message, Color.errorNormal)
        } else {
            return nil
        }
    }

    // MARK: - State
    public var isLoading = false
    public var errorMessage: String?
    public var userList: [AuthSimpleUser] = []
    public var isShowUserList = false
    public var isRequestSent = false
    public var isTimerActive = false
    public var timerRemaining = 180
    public var showAlreadyRegisteredAlert = false
    public var showError = false
    public var skipUserCheck = false
    public var shouldFocusVerificationCode = false

    public var emails: [String] = []
    public var isShowPopup: Bool = false
    public var currentError: AppError?

    private var timerTask: Task<Void, Never>?

    // MARK: password
    public var password: String = ""
    public var checkedPassword: String = ""

    // MARK: profile
    public var nickname: String = ""
    public var birthYear: String = ""
    public var gender: String = ""

    public var user: AuthUser?

    // MARK: Investigate
    public var myIndustry: String = ""
    public var selectedInterests: Set<String> = []
    public var recommendedPost: [AuthRecommendedBrand] = []
    public var isCurationLoading = false

    public init(authRepository: AuthRepository, signupUseCase: SignupUseCase) {
        self.authRepository = authRepository
        self.signupUseCase = signupUseCase
    }

    public func goToNextStep() {
        if let next = SignupStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
            resendFailureCount = 0
            stopTimer()
            isRequestSent = false
            timerRemaining = 180
            showError = false
            skipUserCheck = false
            shouldFocusVerificationCode = false
        }
    }

    public func goToPreviousStep() {
        if let prev = SignupStep(rawValue: currentStep.rawValue - 1) {
            currentStep = prev
            resendFailureCount = 0
            stopTimer()
            isRequestSent = false
            timerRemaining = 180
            showError = false
            skipUserCheck = false
            shouldFocusVerificationCode = false
        }
    }

    public func resetVerificationState() {
           stopTimer()
           isShowPopup = false
           isRequestSent = false
           timerRemaining = 180
           showError = false
           enteredVerificationCode = ""
           resendFailureCount = 0
           verificationCode = ""
           skipUserCheck = false
           shouldFocusVerificationCode = false
       }

    // MARK: - 인증코드 전송 (초기/재전송 공통)
    public func sendVerificationCode(skipCheck: Bool = false) {
        #if DEBUG
        enteredVerificationCode = ""
        showError = false
        timerRemaining = 180
        isRequestSent = true
        startTimer()
        shouldFocusVerificationCode = true
        verificationCode = "121212"
        return
        #endif

        guard resendFailureCount < 3 else {
            isShowPopup = true
            return
        }

        if isRequestSent {
            resendFailureCount += 1
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

                if !skipCheck && !skipUserCheck {
                    let users = try await authRepository.checkPhoneNumber(phoneNumber)
                    if !users.isEmpty {
                        userList = users
                        isShowUserList = true
                        showAlreadyRegisteredAlert = true
                        isLoading = false
                        return
                    }
                }

                let result = try await authRepository.authSMS(phoneNumber: phoneNumber)
                verificationCode = String(result.code)
                await MainActor.run {
                    isRequestSent = true
                    startTimer()
                    shouldFocusVerificationCode = true
                }
            } catch {
                handleError(error, feature: "signup", operation: "sendVerificationCode")
                errorMessage = currentError?.userFacingMessage
                resendFailureCount += 1
            }
            isLoading = false
        }
    }

    // MARK: - 인증번호 검증
    func verifyCode() -> Bool {
        guard isRequestSent else { return false }
        if timerRemaining <= 0 {
            showError = true
            return false
        }

        #if DEBUG
        if enteredVerificationCode == "121212" {
            stopTimer()
            resendFailureCount = 0
            showError = false
            return true
        }
        #endif

        if enteredVerificationCode == verificationCode {
            stopTimer()
            resendFailureCount = 0
            showError = false
            return true
        } else {
            showError = true
            return false
        }
    }

    // MARK: - Timer
    private func startTimer() {
        stopTimer()
        isTimerActive = true
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { break }
                guard self.timerRemaining > 0 else { break }
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                self.timerRemaining -= 1
            }
            if let self, self.timerRemaining <= 0 {
                self.isTimerActive = false
                self.showError = true
            }
        }
    }

    private func stopTimer() {
        isTimerActive = false
        timerTask?.cancel()
        timerTask = nil
    }

    // MARK: - ID Dup Check
    public func checkIDDup() {
        guard SignupFormatStyle.validateID(loginID) == nil else {
            isIDAvailable = nil
            return
        }

        isIDAvailable = nil
        Task { @MainActor in
            do {
                let result = try await authRepository.checkIDDup(loginID)
                switch result {
                case .exists:
                    isIDAvailable = false
                case .notFound:
                    isIDAvailable = true
                }
            } catch {
                isIDAvailable = nil
                handleError(error, feature: "signup", operation: "checkIDDup")
            }
        }
    }

    // MARK: - Interests
    func toggleInterest(_ key: String) {
        if selectedInterests.contains(key) {
            selectedInterests.remove(key)
        } else {
            selectedInterests.insert(key)
        }
    }

    func submitInterests() {
        isCurationLoading = true
        recommendedPost = []
        goToNextStep()

        Task {
            do {
                let result = try await authRepository.preInvestigate(
                    industryId: myIndustry,
                    interestIds: Array(selectedInterests)
                )

                if let currentUserInfo = UserInfoStore.shared.load() {
                    let updatedUserInfo = UserInfo(
                        id: currentUserInfo.id,
                        loginId: currentUserInfo.loginId,
                        phoneNumber: currentUserInfo.phoneNumber,
                        subscribeEmail: currentUserInfo.subscribeEmail,
                        nickname: currentUserInfo.nickname,
                        birthYear: currentUserInfo.birthYear,
                        gender: currentUserInfo.gender,
                        createdAt: currentUserInfo.createdAt,
                        industryId: Int(myIndustry),
                        interestIds: selectedInterests.compactMap { Int($0) }
                    )
                    UserInfoStore.shared.save(updatedUserInfo)
                }

                await MainActor.run {
                    recommendedPost = result
                    isCurationLoading = false
                }
            } catch {
                await MainActor.run {
                    isCurationLoading = false
                    handleError(error, feature: "signup", operation: "submitInterests")
                }
            }
        }
    }

    // MARK: - Signup
    func signup() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                let request = AuthSignupRequest(
                    loginId: loginID,
                    password: password,
                    phoneNumber: phoneNumber,
                    nickname: nickname,
                    birthYear: birthYear,
                    gender: gender
                )

                let resultUser = try await signupUseCase.execute(request: request)
                user = resultUser

                AppState.shared.login()
                isLoading = false
                goToNextStep()
            } catch {
                isLoading = false
                handleError(error, feature: "signup", operation: "signup")
                errorMessage = "회원가입에 실패했습니다"
            }
        }
    }

    // MARK: - 초기화 메서드
    public func reset() {
        currentStep = .phoneVerification

        phoneNumber = ""
        enteredVerificationCode = ""
        verificationCode = ""
        resendFailureCount = 0

        loginID = ""
        isIDAvailable = nil
        password = ""
        nickname = ""
        birthYear = ""
        gender = ""

        user = nil
        recommendedPost = []
        selectedInterests.removeAll()
        myIndustry = ""

        errorMessage = nil
        showError = false
        isLoading = false
        isRequestSent = false
        timerRemaining = 180
        isShowPopup = false

        stopTimer()
        isCurationLoading = false
    }
}
