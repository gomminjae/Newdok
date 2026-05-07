import Foundation
import AuthDomain
import SwiftUI
import Shared

@MainActor
public final class SignupViewModel: ObservableObject, ErrorHandling {
    private let authRepository: AuthRepository
    private let signupUseCase: SignupUseCase

    @Published var currentStep: SignupStep = .phoneVerification

    // MARK: - Form
    @Published public var phoneNumber: String = ""

    var isPhoneNumberValid: Bool {
        SignupFormatStyle.validatePhoneNumber(phoneNumber) == nil
    }
    @Published public var enteredVerificationCode: String = ""
    private var verificationCode: String = ""
    @Published public var resendFailureCount: Int = 0

    // MARK: - ID
    @Published public var loginID: String = "" {
        didSet {
            if oldValue != loginID {
                isIDAvailable = nil
            }
        }
    }
    @Published public var isIDAvailable: Bool?

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
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var userList: [AuthSimpleUser] = []
    @Published public var isShowUserList = false
    @Published public var isRequestSent = false
    @Published public var isTimerActive = false
    @Published public var timerRemaining = 180
    @Published public var showAlreadyRegisteredAlert = false
    @Published public var showError = false
    @Published public var skipUserCheck = false
    @Published public var shouldFocusVerificationCode = false

    @Published public var emails: [String] = []
    @Published public var isShowPopup: Bool = false
    @Published public var currentError: AppError?

    private var timerTask: Task<Void, Never>?

    // MARK: password
    @Published public var password: String = ""
    @Published public var checkedPassword: String = ""

    // MARK: profile
    @Published public var nickname: String = ""
    @Published public var birthYear: String = ""
    @Published public var gender: String = ""

    @Published public var user: AuthUser?

    // MARK: Investigate
    @Published public var myIndustry: String = ""
    @Published public var selectedInterests: Set<String> = []
    @Published public var recommendedPost: [AuthRecommendedBrand] = []
    @Published public var isCurationLoading = false

    public init(authRepository: AuthRepository, signupUseCase: SignupUseCase) {
        self.authRepository = authRepository
        self.signupUseCase = signupUseCase
    }

    deinit {
        timerTask?.cancel()
        timerTask = nil
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
        timerTask = Task {
            while !Task.isCancelled && timerRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                timerRemaining -= 1
            }
            if timerRemaining <= 0 {
                isTimerActive = false
                showError = true
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
