import Testing
import Foundation
import Shared
@testable import Mypage
@testable import MypageTesting
@testable import MypageDomain

@MainActor
private final class StubSelectableItemStore: SelectableItemStoreProtocol {
    var loadState: SelectableOptionsLoadState { .loaded }
    var interests: [SelectableItem] {
        [.init(id: 1, name: "경제"), .init(id: 2, name: "과학"), .init(id: 3, name: "문화")]
    }
    var industries: [SelectableItem] { [.init(id: 5, name: "IT")] }
    var days: [SelectableItem] { [] }
    func loadIfNeeded() async throws {}
    func list(for category: SelectableCategoryType) -> [SelectableItem] {
        switch category {
        case .interest: return interests
        case .industry: return industries
        case .day: return days
        }
    }
    func name(for id: Int, in category: SelectableCategoryType) -> String {
        list(for: category).first(where: { $0.id == id })?.name ?? ""
    }
    func id(for name: String, in category: SelectableCategoryType) -> Int? {
        list(for: category).first(where: { $0.name == name })?.id
    }
}

private final class StubUserInfoStore: UserInfoStoreProtocol, @unchecked Sendable {
    var storedUser: UserInfo?
    func save(_ user: UserInfo) { storedUser = user }
    func load() -> UserInfo? { storedUser }
    func clear() { storedUser = nil }
    var hasProfile: Bool { storedUser?.industryId != nil }
}

private final class StubTokenStorage: TokenStorageProtocol, @unchecked Sendable {
    var accessToken: String?
    var hasValidToken: Bool { accessToken != nil }
    @discardableResult
    func saveAccessToken(_ token: String?) -> Bool { accessToken = token; return true }
    func clear() { accessToken = nil }
    func migrateTokenIfNeeded() {}
}

@Suite("MypageViewModel Tests")
@MainActor
struct MypageViewModelTests {
    private func makeSUT(selectableItemStore: (any SelectableItemStoreProtocol)? = nil) -> (
        vm: MypageViewModel,
        fetchProfile: MockFetchMypageProfileUseCase,
        updateNickname: MockUpdateMypageNicknameUseCase,
        updateInterests: MockUpdateMypageInterestsUseCase,
        updateIndustry: MockUpdateMypageIndustryUseCase
    ) {
        let fetchProfile = MockFetchMypageProfileUseCase()
        let updateNickname = MockUpdateMypageNicknameUseCase()
        let updateInterests = MockUpdateMypageInterestsUseCase()
        let updateIndustry = MockUpdateMypageIndustryUseCase()
        let vm = MypageViewModel(
            fetchProfileUseCase: fetchProfile,
            updateNicknameUseCase: updateNickname,
            updateInterestsUseCase: updateInterests,
            updateIndustryUseCase: updateIndustry,
            selectableItemStore: selectableItemStore ?? StubSelectableItemStore(),
            userInfoStore: StubUserInfoStore()
        )
        return (vm, fetchProfile, updateNickname, updateInterests, updateIndustry)
    }

    @Test("준비되지 않은 옵션으로는 프로필 변경을 제출하지 않는다")
    func blocksUpdatesBeforeOptionsLoad() async {
        let options = SelectableItemStore(fetchOptionsUseCase: MypageOptionsFetcher(result: .failure(MypageOptionsTestError.failed)))
        let (vm, _, _, updateInterests, updateIndustry) = makeSUT(selectableItemStore: options)

        #expect(await vm.updateIndustry(id: 5) == false)
        #expect(await vm.updateInterests(ids: [1, 2, 3]) == false)
        #expect(updateIndustry.executedId == nil)
        #expect(updateInterests.executedIds == nil)
    }

    @Test("옵션 실패·재시도가 저장된 프로필과 다른 오류 상태를 지우지 않는다")
    func optionsRetryPreservesProfile() async throws {
        let fetcher = MypageOptionsFetcher(result: .failure(MypageOptionsTestError.failed))
        let options = SelectableItemStore(fetchOptionsUseCase: fetcher)
        let (vm, _, _, _, _) = makeSUT(selectableItemStore: options)
        vm.user = MypageUser(id: 1, subscribeEmail: nil, nickname: "기존 닉네임", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 5, interests: [])
        vm.currentError = .userMessage("다른 작업 오류")

        await #expect(throws: MypageOptionsTestError.self) { try await vm.loadOptions() }
        #expect(vm.optionsLoadState == .failed)
        #expect(vm.user?.industryId == 5)

        fetcher.setResult(.success(SelectableOptions(
            interests: [.init(id: 1, name: "경제"), .init(id: 2, name: "과학"), .init(id: 3, name: "문화")],
            industries: [.init(id: 5, name: "IT")], days: []
        )))
        try await vm.loadOptions()

        #expect(vm.optionsLoadState == .loaded)
        #expect(vm.industryName(for: 5) == "IT")
        #expect(vm.user?.nickname == "기존 닉네임")
        #expect(vm.currentError == .userMessage("다른 작업 오류"))
        #expect(!vm.canUpdateIndustry(id: 999))
        #expect(!vm.canUpdateInterests(ids: [1, 2, 999]))
        #expect(vm.canUpdateInterests(ids: [1, 2, 3]))
    }

    @Test func fetchUserInfo_success() async {
        let (vm, fetchProfile, _, _, _) = makeSUT()
        let user = MypageUser(id: 1, subscribeEmail: nil, nickname: "닉네임", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interests: [])
        fetchProfile.result = .success(user)

        await vm.fetchuserInfo()

        #expect(fetchProfile.executeCallCount == 1)
        #expect(vm.user?.nickname == "닉네임")
    }

    @Test func updateNickname_success() async {
        let (vm, _, updateNickname, _, _) = makeSUT()
        vm.user = MypageUser(id: 1, subscribeEmail: nil, nickname: "이전", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interests: [])

        let success = await vm.updateNickname(nickname: "새닉네임")

        #expect(success == true)
        #expect(updateNickname.executedNickname == "새닉네임")
        #expect(vm.showNicknameSuccess == true)
    }

    @Test func updateNickname_failure() async {
        let (vm, _, updateNickname, _, _) = makeSUT()
        updateNickname.result = .failure(NSError(domain: "test", code: -1))

        let success = await vm.updateNickname(nickname: "새닉네임")

        #expect(success == false)
    }

    @Test func updateIndustry_success() async {
        let (vm, _, _, _, updateIndustry) = makeSUT()
        vm.user = MypageUser(id: 1, subscribeEmail: nil, nickname: "테스트", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interests: [])

        let success = await vm.updateIndustry(id: 5)

        #expect(success == true)
        #expect(updateIndustry.executedId == 5)
        #expect(vm.showIndustrySuccess == true)
    }

    @Test func updateInterests_success() async {
        let (vm, _, _, updateInterests, _) = makeSUT()
        vm.user = MypageUser(id: 1, subscribeEmail: nil, nickname: "테스트", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interests: [])

        let success = await vm.updateInterests(ids: [1, 2, 3])

        #expect(success == true)
        #expect(updateInterests.executedIds == [1, 2, 3])
        #expect(vm.showInterestSuccess == true)
    }

}

private enum MypageOptionsTestError: Error { case failed }

@MainActor
private final class MypageOptionsFetcher: FetchSelectableOptionsUseCase {
    private var result: Result<SelectableOptions, Error>
    init(result: Result<SelectableOptions, Error>) { self.result = result }
    func execute() async throws -> SelectableOptions { try result.get() }
    func setResult(_ result: Result<SelectableOptions, Error>) { self.result = result }
}

@Suite("WithdrawViewModel Tests")
@MainActor
struct WithdrawViewModelTests {
    private func makeSUT() -> (
        vm: WithdrawViewModel,
        fetchProfile: MockFetchMypageProfileUseCase,
        fetchSubCount: MockFetchMypageSubscriptionCountUseCase,
        fetchArticleCount: MockFetchReceivedArticleCountUseCase,
        withdraw: MockMypageWithdrawUseCase
    ) {
        let fetchProfile = MockFetchMypageProfileUseCase()
        let fetchSubCount = MockFetchMypageSubscriptionCountUseCase()
        let fetchArticleCount = MockFetchReceivedArticleCountUseCase()
        let withdraw = MockMypageWithdrawUseCase()
        let vm = WithdrawViewModel(
            fetchProfileUseCase: fetchProfile,
            fetchSubscriptionCountUseCase: fetchSubCount,
            fetchArticleCountUseCase: fetchArticleCount,
            withdrawUseCase: withdraw,
            tokenStorage: StubTokenStorage(),
            userInfoStore: StubUserInfoStore(),
            appState: AppState.shared
        )
        return (vm, fetchProfile, fetchSubCount, fetchArticleCount, withdraw)
    }

    @Test func fetchUserInfo_success() async {
        let (vm, fetchProfile, fetchSubCount, fetchArticleCount, _) = makeSUT()
        fetchProfile.result = .success(
            MypageUser(id: 1, subscribeEmail: nil, nickname: "유저", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interests: [])
        )
        fetchSubCount.result = .success(3)
        fetchArticleCount.result = .success(15)

        await vm.fetchUserInfo()

        #expect(vm.nickName == "유저")
        #expect(vm.newsletterCount == 3)
        #expect(vm.articleCount == 15)
    }

    @Test func withdraw_success() async {
        let (vm, _, _, _, withdraw) = makeSUT()
        AppState.shared.login()

        await vm.withdraw()

        #expect(withdraw.executeCallCount == 1)
        #expect(vm.withdrawSuccess == true)
        #expect(AppState.shared.authState == .guest)
    }

    @Test func withdraw_failure_keepsAuthenticatedState() async {
        let (vm, _, _, _, withdraw) = makeSUT()
        withdraw.result = .failure(NSError(domain: "test", code: -1))
        AppState.shared.login()

        await vm.withdraw()

        #expect(withdraw.executeCallCount == 1)
        #expect(vm.withdrawSuccess == false)
        #expect(AppState.shared.authState == .authenticated)
    }
}
