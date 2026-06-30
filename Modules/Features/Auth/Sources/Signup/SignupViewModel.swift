import Foundation
import AuthDomain
import SwiftUI
import Shared
import FoundationKit
import Observation

@Observable
@MainActor
public final class SignupViewModel: ErrorHandling {
    private let authRepository: AuthRepository
    private let signupUseCase: SignupUseCase
    private let userInfoStore: UserInfoStoreProtocol
    private let selectableItemStore: SelectableItemStoreProtocol
    private let appState: AppState

    private let signupToken: String

    var currentStep: SignupStep = .enterProfile

    // MARK: - State
    public var isLoading = false
    public var errorMessage: String?
    public var currentError: AppError?

    private var interestsTask: Task<Void, Never>?
    private var signupTask: Task<Void, Never>?

    // MARK: - Profile
    public var nickname: String = ""
    public var birthYear: String = ""
    public var gender: String = ""

    // MARK: - Agreements
    public var agreeOver14: Bool = false
    public var agreeService: Bool = false
    public var agreePersonalInfo: Bool = false
    public var agreeMarketing: Bool = false

    public var user: AuthUser?

    // MARK: - Investigate
    public var myIndustry: String = ""
    public var selectedInterests: Set<String> = []
    public var recommendedPost: [AuthRecommendedBrand] = []
    public var isCurationLoading = false

    public init(
        signupToken: String,
        suggestedNickname: String?,
        authRepository: AuthRepository,
        signupUseCase: SignupUseCase,
        userInfoStore: UserInfoStoreProtocol,
        selectableItemStore: SelectableItemStoreProtocol,
        appState: AppState
    ) {
        self.signupToken = signupToken
        self.nickname = suggestedNickname ?? ""
        self.authRepository = authRepository
        self.signupUseCase = signupUseCase
        self.userInfoStore = userInfoStore
        self.selectableItemStore = selectableItemStore
        self.appState = appState
    }

    var industries: [SelectableItem] {
        selectableItemStore.list(for: .industry)
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

        interestsTask?.cancel()
        interestsTask = Task {
            do {
                let result = try await authRepository.preInvestigate(
                    industryId: myIndustry,
                    interestIds: Array(selectedInterests)
                )

                if let currentUserInfo = userInfoStore.load() {
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
                    userInfoStore.save(updatedUserInfo)
                }

                await MainActor.run {
                    recommendedPost = result
                    isCurationLoading = false
                }
            } catch {
                guard !Task.isCancelled else { return }
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
        signupTask?.cancel()
        signupTask = Task {
            do {
                let request = AuthSignupRequest(
                    signupToken: signupToken,
                    nickname: nickname,
                    birthYear: birthYear,
                    gender: gender,
                    agreements: [
                        AuthAgreement(type: .ageConfirmationOver14, agreed: agreeOver14),
                        AuthAgreement(type: .termsOfService, agreed: agreeService),
                        AuthAgreement(type: .personalInformation, agreed: agreePersonalInfo),
                        AuthAgreement(type: .marketing, agreed: agreeMarketing)
                    ]
                )

                let resultUser = try await signupUseCase.execute(request: request)
                user = resultUser

                appState.login()
                isLoading = false
                goToNextStep()
            } catch {
                guard !Task.isCancelled else { return }
                isLoading = false
                handleError(error, feature: "signup", operation: "signup")
                errorMessage = "회원가입에 실패했습니다"
            }
        }
    }
}
