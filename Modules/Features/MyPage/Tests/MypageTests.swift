import Testing
import Foundation
import Shared
@testable import Mypage
@testable import MypageTesting
@testable import MypageDomain

private final class StubSelectableItemStore: SelectableItemStoreProtocol, @unchecked Sendable {
    var interests: [SelectableItem] { [] }
    var industries: [SelectableItem] { [] }
    var days: [SelectableItem] { [] }
    func loadOptions(interests: [SelectableItem], industries: [SelectableItem], days: [SelectableItem]) {}
    func list(for category: SelectableCategoryType) -> [SelectableItem] { [] }
    func name(for id: Int, in category: SelectableCategoryType) -> String { "" }
    func id(for name: String, in category: SelectableCategoryType) -> Int? { nil }
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
    private func makeSUT() -> (
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
            selectableItemStore: StubSelectableItemStore(),
            userInfoStore: StubUserInfoStore()
        )
        return (vm, fetchProfile, updateNickname, updateInterests, updateIndustry)
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
