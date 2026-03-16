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
public final class SignupViewModel: ObservableObject, ErrorHandling {
    private let userUseCase: UserUseCase
    private let signupUseCase: SignupUseCase

    @Published var currentStep: SignupStep = .phoneVerification

    // MARK: - Form
    @Published public var phoneNumber: String = ""
    @Published public var enteredVerificationCode: String = ""
    private var verificationCode: String = ""
    @Published public var resendFailureCount: Int = 0

    // MARK: - ID
    @Published public var loginID: String = "" {
        didSet {
            // 실제로 값이 변경되었을 때만 초기화
            if oldValue != loginID {
                isIDAvailable = nil
            }
        }
    }
    @Published public var isIDAvailable: Bool?

    var idValidationError: IDValidationError? {
        guard !loginID.isEmpty else { return nil }
        return validateID()
    }

    var isIDCheckEnabled: Bool { validateID() == nil }

    var isIDErrorState: Bool {
        guard !loginID.isEmpty else { return false }
        if isIDAvailable == false { return true }
        if isIDAvailable == nil, validateID() != nil { return true }
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
    @Published public var userList: [SimpleUser] = []
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

    @Published public var user: User?

    // MARK: Investigate
    @Published public var myIndustry: String = ""
    @Published public var selectedInterests: Set<String> = []
    @Published public var recommendedPost: [RecommendedBrand] = []
    @Published public var isCurationLoading = false

    public init(userUseCase: UserUseCase, signupUseCase: SignupUseCase) {
        self.userUseCase = userUseCase
        self.signupUseCase = signupUseCase
    }

    deinit {
        timerTask?.cancel()
        timerTask = nil
    }

    public func goToNextStep() {
        if let next = SignupStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
            // 인증 관련 상태 초기화
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
            // 인증 관련 상태 초기화
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
        // 테스트 앱에서는 API 호출 없이 바로 인증 상태로 전환
        #if DEBUG
        enteredVerificationCode = ""
        showError = false
        timerRemaining = 180
        isRequestSent = true
        startTimer()
        shouldFocusVerificationCode = true
        verificationCode = "121212" // 테스트용 고정 코드
        return
        #endif

        // 재전송 3회 초과 시, 팝업 표시
        guard resendFailureCount < 3 else {
            isShowPopup = true
            return
        }

        // 재전송인 경우 카운트 증가 (초기 전송이 아닌 경우)
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
                await MainActor.run {
                    isRequestSent = true
                    startTimer()
                    shouldFocusVerificationCode = true  // 인증번호 입력 필드로 포커스
                }
            } catch {
                handleError(error, feature: "signup", operation: "sendVerificationCode")
                errorMessage = currentError?.userFacingMessage
                // 전송 실패 시에만 카운트 증가
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

        // 테스트 앱에서는 121212도 통과
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
            // 성공 시 제한/에러 상태 초기화
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

    // MARK: - ID Validation / Dup Check
    public func validateID() -> IDValidationError? {
        let id = loginID
        let isValidLength = (6...12).contains(id.count)
        let hasLetter = id.rangeOfCharacter(from: .letters) != nil
        let hasNumber = id.rangeOfCharacter(from: .decimalDigits) != nil
        let isAlphanumeric = hasLetter && hasNumber

        let allowedCharset = CharacterSet.alphanumerics
        let containsOnlyAllowed = id.rangeOfCharacter(from: allowedCharset.inverted) == nil

        if !isValidLength && (!isAlphanumeric || !containsOnlyAllowed) {
            return .invalidLengthAndCombination
        }
        if !isValidLength { return .invalidLength }
        if !isAlphanumeric || !containsOnlyAllowed { return .invalidCombination }
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
                let result = try await userUseCase.preInvestigate(
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
                let request = SignupRequest(
                    loginId: loginID,
                    password: password,
                    phoneNumber: phoneNumber,
                    nickname: nickname,
                    birthYear: birthYear,
                    gender: gender
                )

                let resultUser = try await signupUseCase.execute(request: request)
                user = resultUser

                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(false, forKey: "isGuest")
                UserDefaults.standard.set(resultUser.nickname, forKey: "nickname")
                UserDefaults.standard.set(resultUser.subscribeEmail ?? "", forKey: "email")

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
