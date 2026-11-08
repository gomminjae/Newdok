import Foundation
import AuthDomain
import SwiftUI
import Shared
import FoundationKit
import Observation

@Observable
@MainActor
public final class SignupViewModel: ErrorHandling {
    public let context: AuthAnalyticsContext
    private var didTrackProfile = false
    private(set) var subscriptionSession: SubscriptionAnalyticsSession?
    func startSubscription(_ brand: AuthRecommendedBrand) -> Bool {
        guard subscriptionSession == nil else { return false }
        subscriptionSession = SubscriptionAnalyticsSession(newsletter: .init(id: String(brand.id), name: brand.name), url: brand.subscribeUrl, client: analytics, from: .signupCuration, status: .unknown)
        return subscriptionSession != nil
    }
    func closeSubscription() {
        subscriptionSession?.pageClosed()
        subscriptionSession = nil
    }
    private(set) var curationList = AnalyticsListContext(.signupCuration)
    func skipProfile() {
        guard !didTrackProfile else { return }
        didTrackProfile = true
        analytics.record(.profileSetupFinished(flowID: context.flowID, outcome: .skipped), from: .signup)
    }
    public let analytics: AnalyticsClient

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

    private(set) var interestsTask: Task<Void, Never>?
    private(set) var signupTask: Task<Void, Never>?

    func cancelPendingWork() {
        interestsTask?.cancel()
        signupTask?.cancel()
    }

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
        appState: AppState,
        context: AuthAnalyticsContext = AuthAnalyticsContext(),
        analytics: AnalyticsClient = .disabled
    ) {
        self.context = context
        self.analytics = analytics
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

    var interests: [SelectableItem] {
        selectableItemStore.list(for: .interest)
    }

    var optionsLoadState: SelectableOptionsLoadState { selectableItemStore.loadState }

    func loadOptions() async throws {
        try await selectableItemStore.loadIfNeeded()
    }

    var canContinueIndustry: Bool {
        optionsLoadState == .loaded && industries.contains { String($0.id) == myIndustry }
    }

    var canSubmitInterests: Bool {
        canContinueIndustry && !isCurationLoading && selectedInterests.count >= 3
            && selectedInterests.isSubset(of: Set(interests.map { String($0.id) }))
    }

    public func goToNextStep() {
        if currentStep == .myIndustry && !canContinueIndustry { return }
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
        guard canSubmitInterests else { return }
        curationList = .init(.signupCuration)
        isCurationLoading = true
        recommendedPost = []
        goToNextStep()

        interestsTask?.cancel()
        interestsTask = Task {
            defer { isCurationLoading = false }
            do {
                let result = try await authRepository.preInvestigate(
                    industryId: myIndustry,
                    interestIds: Array(selectedInterests)
                )

                try Task.checkCancellation()
                if let currentUserInfo = userInfoStore.load() {
                    let updatedUserInfo = UserInfo(
                        id: currentUserInfo.id,
                        subscribeEmail: currentUserInfo.subscribeEmail,
                        nickname: currentUserInfo.nickname,
                        birthYear: currentUserInfo.birthYear,
                        gender: currentUserInfo.gender,
                        createdAt: currentUserInfo.createdAt,
                        industryId: Int(myIndustry),
                        interestIds: selectedInterests.compactMap { Int($0) }
                    )
                    userInfoStore.save(updatedUserInfo)
                    if !didTrackProfile {
                        didTrackProfile = true
                        analytics.record(.profileSetupFinished(flowID: context.flowID, outcome: .completed), from: .signup)
                    }
                }

                await MainActor.run {
                    recommendedPost = result
                    isCurationLoading = false
                }
            } catch {
                guard !Task.isCancelled, !(error is CancellationError) else { return }
                await MainActor.run {
                    isCurationLoading = false
                    analytics.record(.operationFailed(.profile(flowID: context.flowID), category: .init(error: error)), from: .signup)
                    handleError(error, feature: "signup", operation: "submitInterests")
                }
            }
        }
    }

    // MARK: - Signup
    func signup() {
        guard !isLoading, user == nil else { return }
        isLoading = true
        signupTask?.cancel()
        signupTask = Task {
            defer { isLoading = false }
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
                try Task.checkCancellation()
                user = resultUser

                appState.login()
                if let method = context.method { analytics.record(.signUp(flowID: context.flowID, method: method), from: .signup) }
                isLoading = false
                goToNextStep()
            } catch {
                guard !Task.isCancelled, !(error is CancellationError) else { return }
                isLoading = false
                analytics.record(.operationFailed(.signup(flowID: context.flowID), category: .init(error: error)), from: .signup)
                handleError(error, feature: "signup", operation: "signup")
                errorMessage = "회원가입에 실패했습니다"
            }
        }
    }
}
