import Foundation
import Testing
import Synchronization
import Shared
import AuthDomain
@testable import Auth

@Suite("회원가입 공통 선택 목록")
@MainActor
struct SignupOptionsTests {
    private static let options = SelectableOptions(
        interests: [.init(id: 10, name: "서버 관심사 A"), .init(id: 20, name: "서버 관심사 B"), .init(id: 30, name: "서버 관심사 C")],
        industries: [.init(id: 8, name: "서버 산업")],
        days: []
    )

    private func makeViewModel(fetcher: SignupOptionsFetcher) -> SignupViewModel {
        SignupViewModel(
            signupToken: "test-signup-token",
            suggestedNickname: nil,
            authRepository: UnusedAuthRepository(),
            signupUseCase: UnusedSignupUseCase(),
            userInfoStore: EmptyUserInfoStore(),
            selectableItemStore: SelectableItemStore(fetchOptionsUseCase: fetcher),
            appState: AppState()
        )
    }

    @Test("준비 전에는 산업 단계 진행과 관심사 제출을 막는다")
    func blocksUntilReady() async {
        let vm = makeViewModel(fetcher: SignupOptionsFetcher(result: .success(Self.options)))
        vm.currentStep = .myIndustry
        vm.myIndustry = "8"
        vm.selectedInterests = ["10", "20", "30"]

        vm.goToNextStep()
        vm.submitInterests()

        #expect(vm.currentStep == .myIndustry)
        #expect(!vm.canContinueIndustry)
        #expect(!vm.canSubmitInterests)
        #expect(!vm.isCurationLoading)
    }

    @Test("서버 목록을 사용하고 준비 완료가 편집 중 선택을 초기화하지 않는다")
    func usesServerOptionsAndPreservesSelection() async throws {
        let vm = makeViewModel(fetcher: SignupOptionsFetcher(result: .success(Self.options)))
        vm.currentStep = .myIndustry
        vm.myIndustry = "8"
        vm.selectedInterests = ["10", "20", "30"]

        try await vm.loadOptions()

        #expect(vm.industries == Self.options.industries)
        #expect(vm.interests == Self.options.interests)
        #expect(vm.myIndustry == "8")
        #expect(vm.selectedInterests == ["10", "20", "30"])
        #expect(vm.canSubmitInterests)
        vm.goToNextStep()
        #expect(vm.currentStep == .industryList)
    }

    @Test("서버 목록에 없는 ID와 정상 빈 목록은 제출할 수 없다")
    func rejectsUnknownSelections() async throws {
        let vm = makeViewModel(fetcher: SignupOptionsFetcher(result: .success(Self.options)))
        try await vm.loadOptions()
        vm.myIndustry = "8"
        vm.selectedInterests = ["10", "20", "999"]
        #expect(!vm.canSubmitInterests)
        vm.myIndustry = "999"
        #expect(!vm.canContinueIndustry)

        let emptyVM = makeViewModel(fetcher: SignupOptionsFetcher(result: .success(
            SelectableOptions(interests: [], industries: [], days: [])
        )))
        try await emptyVM.loadOptions()
        #expect(emptyVM.optionsLoadState == .loaded)
        #expect(!emptyVM.canContinueIndustry)
        #expect(!emptyVM.canSubmitInterests)
    }

    @Test("옵션 오류는 회원가입 오류와 분리하고 재시도할 수 있다")
    func retryDoesNotResetSignup() async throws {
        let fetcher = SignupOptionsFetcher(result: .failure(OptionsTestError.failed))
        let vm = makeViewModel(fetcher: fetcher)
        vm.nickname = "작성 중"
        vm.currentStep = .myIndustry
        await #expect(throws: OptionsTestError.self) { try await vm.loadOptions() }
        #expect(vm.optionsLoadState == .failed)
        #expect(vm.currentError == nil)

        fetcher.setResult(.success(Self.options))
        try await vm.loadOptions()
        #expect(vm.optionsLoadState == .loaded)
        #expect(vm.nickname == "작성 중")
        #expect(vm.currentStep == .myIndustry)
    }
    @Test("회원가입 성공은 한 번만 기록하며 프로필 건너뛰기와 별도로 연결한다")
    func accountCreationMeasurement() async {
        let recorder = SignupAnalyticsRecorder()
        let context = AuthAnalyticsContext()
        let attempt = context.beginAttempt(method: .apple)
        context.finishAttempt(attempt)
        let vm = SignupViewModel(
            signupToken: "전송 금지 토큰", suggestedNickname: "개인 이름",
            authRepository: UnusedAuthRepository(), signupUseCase: SuccessfulSignupUseCase(),
            userInfoStore: EmptyUserInfoStore(),
            selectableItemStore: SelectableItemStore(fetchOptionsUseCase: SignupOptionsFetcher(result: .success(Self.options))),
            appState: AppState(), context: context, analytics: recorder.client
        )
        vm.currentStep = .agreeTerms
        vm.signup()
        await vm.signupTask?.value
        vm.signup()
        await vm.signupTask?.value
        vm.skipProfile()
        vm.skipProfile()
        #expect(recorder.payloads.map(\.name) == ["sign_up", "profile_setup_finished"])
        #expect(recorder.payloads.last?.parameters["outcome"] == .string("skipped"))
        #expect(recorder.payloads.allSatisfy { $0.parameters["auth_flow_id"] == .string(context.flowID.uuidString.lowercased()) })
    }

    @Test("프로필 저장 성공 뒤에만 완료하며 추천 목록이 비어도 완료를 유지한다")
    func profileCommitMeasurement() async throws {
        let recorder = SignupAnalyticsRecorder()
        let store = SignupUserStore()
        let vm = SignupViewModel(
            signupToken: "token", suggestedNickname: nil,
            authRepository: SuccessfulProfileRepository(), signupUseCase: UnusedSignupUseCase(),
            userInfoStore: store,
            selectableItemStore: SelectableItemStore(fetchOptionsUseCase: SignupOptionsFetcher(result: .success(Self.options))),
            appState: AppState(), analytics: recorder.client
        )
        try await vm.loadOptions()
        vm.currentStep = .industryList
        vm.myIndustry = "8"
        vm.selectedInterests = ["10", "20", "30"]
        vm.submitInterests()
        await vm.interestsTask?.value
        #expect(store.load()?.industryId == 8)
        #expect(vm.recommendedPost.isEmpty)
        #expect(recorder.payloads.map(\.name) == ["profile_setup_finished"])
        #expect(recorder.payloads.last?.parameters["outcome"] == .string("completed"))
    }

    @Test("취소된 가입은 성공과 오류로 기록하지 않고 다시 시도할 수 있다")
    func cancelledSignupMeasurement() async {
        let recorder = SignupAnalyticsRecorder()
        let vm = SignupViewModel(
            signupToken: "token", suggestedNickname: nil,
            authRepository: UnusedAuthRepository(), signupUseCase: CancelledSignupUseCase(),
            userInfoStore: EmptyUserInfoStore(),
            selectableItemStore: SelectableItemStore(fetchOptionsUseCase: SignupOptionsFetcher(result: .success(Self.options))),
            appState: AppState(), analytics: recorder.client
        )
        vm.signup()
        await vm.signupTask?.value
        #expect(recorder.payloads.isEmpty)
        #expect(!vm.isLoading)
        #expect(vm.currentError == nil)
    }

}

private enum OptionsTestError: Error { case failed }

@MainActor
private final class SignupOptionsFetcher: FetchSelectableOptionsUseCase {
    private var result: Result<SelectableOptions, Error>
    init(result: Result<SelectableOptions, Error>) { self.result = result }
    func execute() async throws -> SelectableOptions { try result.get() }
    func setResult(_ result: Result<SelectableOptions, Error>) { self.result = result }
}

private final class EmptyUserInfoStore: UserInfoStoreProtocol, Sendable {
    func save(_ user: UserInfo) {}
    func load() -> UserInfo? { nil }
    func clear() {}
    var hasProfile: Bool { false }
}

private struct UnusedSignupUseCase: SignupUseCase {
    func execute(request: AuthSignupRequest) async throws -> AuthUser {
        throw OptionsTestError.failed
    }
}

private struct UnusedAuthRepository: AuthRepository {
    func login(credential: SocialLoginCredential) async throws -> SocialLoginResultType {
        throw OptionsTestError.failed
    }
    func signup(signupToken: String, nickname: String, birthYear: String, gender: String, agreements: [AuthAgreement]) async throws -> AuthSignupResponse {
        throw OptionsTestError.failed
    }
    func preInvestigate(industryId: String, interestIds: [String]) async throws -> [AuthRecommendedBrand] {
        throw OptionsTestError.failed
    }
    func signOut() async {}
}

private struct SuccessfulSignupUseCase: SignupUseCase {
    func execute(request: AuthSignupRequest) async throws -> AuthUser {
        AuthUser(id: 1, subscribeEmail: nil, nickname: "개인 이름", birthYear: "2000", gender: "", createdAt: "", industryId: nil, interestIds: [])
    }
}
private struct CancelledSignupUseCase: SignupUseCase {
    func execute(request: AuthSignupRequest) async throws -> AuthUser { throw CancellationError() }
}
private struct SuccessfulProfileRepository: AuthRepository {
    func login(credential: SocialLoginCredential) async throws -> SocialLoginResultType { throw OptionsTestError.failed }
    func signup(signupToken: String, nickname: String, birthYear: String, gender: String, agreements: [AuthAgreement]) async throws -> AuthSignupResponse { throw OptionsTestError.failed }
    func preInvestigate(industryId: String, interestIds: [String]) async throws -> [AuthRecommendedBrand] { [] }
    func signOut() async {}
}
private final class SignupUserStore: UserInfoStoreProtocol {
    private let storage = Mutex<UserInfo?>(UserInfo(id: 1, subscribeEmail: "private@example.com", nickname: "이름", birthYear: "", gender: "", createdAt: "", interestIds: []))
    func save(_ user: UserInfo) { storage.withLock { $0 = user } }
    func load() -> UserInfo? { storage.withLock { $0 } }
    func clear() { storage.withLock { $0 = nil } }
    var hasProfile: Bool { load()?.industryId != nil }
}
@MainActor private final class SignupAnalyticsRecorder {
    var payloads: [AnalyticsPayload] = []
    var client: AnalyticsClient {
        AnalyticsClient { [self] event, source in
            if let payload = event.payload(common: .init(environment: .development, build: "1", authState: .authenticated), from: source) { payloads.append(payload) }
        }
    }
}
