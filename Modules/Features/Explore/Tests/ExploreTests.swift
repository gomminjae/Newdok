import Testing
import Foundation
import Synchronization
import Shared
@testable import Explore
@testable import ExploreTesting
@testable import ExploreDomain

private final class StubUserInfoStore: UserInfoStoreProtocol {
    private let storage = Mutex<UserInfo?>(nil)
    var storedUser: UserInfo? {
        get { storage.withLock { $0 } }
        set { storage.withLock { $0 = newValue } }
    }
    func save(_ user: UserInfo) { storedUser = user }
    func load() -> UserInfo? { storedUser }
    func clear() { storedUser = nil }
    var hasProfile: Bool {
        guard let user = storedUser else { return false }
        return !user.nickname.isEmpty && user.industryId != nil && !user.interestIds.isEmpty
    }
}

private final class StubSelectableItemStore: SelectableItemStoreProtocol, @unchecked Sendable {
    var interests: [SelectableItem] { [] }
    var industries: [SelectableItem] { [] }
    var days: [SelectableItem] { [] }
    func loadOptions(interests: [SelectableItem], industries: [SelectableItem], days: [SelectableItem]) {}
    func list(for category: SelectableCategoryType) -> [SelectableItem] { [] }
    func name(for id: Int, in category: SelectableCategoryType) -> String { "" }
    func id(for name: String, in category: SelectableCategoryType) -> Int? { nil }
}

@Suite("ExploreViewModel Tests")
@MainActor
struct ExploreViewModelTests {
    enum ProfileEdit: CaseIterable, Sendable {
        case nickname, industry, interests
    }

    private func makeSUT(
        userInfoStore: StubUserInfoStore = .init(),
        recommendationUseCase: (any FetchExploreRecommendationUseCase)? = nil
    ) -> (
        vm: ExploreViewModel,
        fetchNewsletters: MockFetchExploreNewslettersUseCase,
        fetchGuest: MockFetchGuestExploreNewslettersUseCase,
        fetchRecommendation: MockFetchExploreRecommendationUseCase
    ) {
        let fetchNewsletters = MockFetchExploreNewslettersUseCase()
        let fetchGuest = MockFetchGuestExploreNewslettersUseCase()
        let fetchRecommendation = MockFetchExploreRecommendationUseCase()
        let appState = AppState()
        appState.login()
        let vm = ExploreViewModel(
            fetchNewslettersUseCase: fetchNewsletters,
            fetchGuestNewslettersUseCase: fetchGuest,
            fetchRecommendationUseCase: recommendationUseCase ?? fetchRecommendation,
            transformRecommendationUseCase: MockTransformExploreRecommendationUseCase(),
            prioritizeInterestsUseCase: MockPrioritizeInterestsUseCase(),
            userInfoStore: userInfoStore,
            selectableItemStore: StubSelectableItemStore(),
            appState: appState
        )
        return (vm, fetchNewsletters, fetchGuest, fetchRecommendation)
    }

    @Test func fetchAllNewsletters_success() async {
        let (vm, fetchNewsletters, _, _) = makeSUT()
        let brands = [
            ExploreBrand(brandId: 1, brandName: "뉴스레터A", imageUrl: nil, interests: [], isSubscribed: nil, shortDescription: "설명", subscriptionCount: 100)
        ]
        fetchNewsletters.result = .success(brands)

        await vm.fetchAllNewsletters()

        #expect(fetchNewsletters.executeCallCount == 1)
        #expect(vm.allNewsletters.count == 1)
        #expect(vm.allNewsletters.first?.brandName == "뉴스레터A")
    }

    @Test func fetchAllNewsletters_failure() async {
        let (vm, fetchNewsletters, _, _) = makeSUT()
        fetchNewsletters.result = .failure(NSError(domain: "test", code: -1))

        await vm.fetchAllNewsletters()

        #expect(vm.allNewsletters.isEmpty)
    }

    @Test func fetchGuestAllNewsletters_success() async {
        let (vm, _, fetchGuest, _) = makeSUT()
        let brands = [
            ExploreBrand(brandId: 2, brandName: "게스트B", imageUrl: nil, interests: [], isSubscribed: nil, shortDescription: "설명", subscriptionCount: 50)
        ]
        fetchGuest.result = .success(brands)

        await vm.fetchGuestAllNewsletters()

        #expect(fetchGuest.executeCallCount == 1)
        #expect(vm.allNewsletters.count == 1)
    }

    @Test func fetchRecommendation_success() async {
        let (vm, _, _, fetchRecommendation) = makeSUT()
        let recommendation = ExploreRecommendedNewsletter(union: [], intersection: [])
        fetchRecommendation.result = .success(recommendation)

        await vm.fetchRecommendation(forceRefresh: true)

        #expect(fetchRecommendation.executeCallCount == 1)
    }

    @Test("프로필이 그대로면 복귀 시 추천 캐시를 재사용한다")
    func returnWithoutProfileChange_usesCache() async {
        let store = StubUserInfoStore()
        store.save(Self.profile)
        let (vm, _, _, recommendation) = makeSUT(userInfoStore: store)

        await vm.loadInitial()
        await vm.loadInitial()

        #expect(recommendation.executeCallCount == 1)
        #expect(vm.isInitialLoaded)
    }

    @Test("프로필 변경 후 복귀하면 5분 이내에도 추천을 재조회한다", arguments: ProfileEdit.allCases)
    func returnAfterProfileChange_reloadsRecommendation(field: ProfileEdit) async {
        let store = StubUserInfoStore()
        store.save(Self.profile)
        let (vm, _, _, recommendation) = makeSUT(userInfoStore: store)
        await vm.loadInitial()

        var changed = Self.profile
        switch field {
        case .nickname: changed.nickname = "새 닉네임"
        case .industry: changed.industryId = 2
        case .interests: changed.interestIds = [2, 3]
        }
        store.save(changed)
        await vm.loadInitial()

        #expect(recommendation.executeCallCount == 2)
        #expect(vm.nickname == changed.nickname)
        #expect(vm.hasUserProfile)
        #expect(vm.isInitialLoaded)
    }

    @Test("닉네임이 같아도 프로필 설정 완료가 복귀 화면에 반영된다")
    func completedProfile_updatesPresentation() async {
        let store = StubUserInfoStore()
        var incomplete = Self.profile
        incomplete.industryId = nil
        incomplete.interestIds = []
        store.save(incomplete)
        let (vm, _, _, recommendation) = makeSUT(userInfoStore: store)
        await vm.loadInitial()
        #expect(!vm.hasUserProfile)

        store.save(Self.profile)
        vm.reloadUserInfo()
        #expect(vm.hasUserProfile)
        #expect(!vm.isInitialLoaded)
        await vm.loadInitial()

        #expect(recommendation.executeCallCount == 2)
        #expect(vm.isInitialLoaded)
    }

    @Test("변경된 프로필 조회가 실패해도 이전 추천 캐시를 되살리지 않는다")
    func profileReloadFailure_doesNotReuseOldCache() async {
        let store = StubUserInfoStore()
        store.save(Self.profile)
        let (vm, _, _, recommendation) = makeSUT(userInfoStore: store)
        await vm.loadInitial()

        var changed = Self.profile
        changed.interestIds = [2]
        store.save(changed)
        recommendation.result = .failure(NSError(domain: "test", code: -1))
        await vm.fetchRecommendation()
        #expect(vm.currentError != nil)

        recommendation.result = .success(.init(union: [], intersection: []))
        await vm.fetchRecommendation()
        #expect(recommendation.executeCallCount == 3)
        #expect(vm.currentError == nil)
    }

    private static var profile: UserInfo {
        UserInfo(id: 1, nickname: "테스터", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interestIds: [1])
    }

    @Test("프로필 변경 전 요청이 늦게 끝나도 최신 추천을 덮어쓰지 않는다")
    func lateResponseAfterProfileChange_isIgnored() async {
        let store = StubUserInfoStore()
        store.save(Self.profile)
        let controlled = ControlledRecommendationUseCase()
        let (vm, _, _, _) = makeSUT(userInfoStore: store, recommendationUseCase: controlled)
        let previous = Task { await vm.fetchRecommendation() }
        await controlled.requests.waitUntilRequested(1)

        var changed = Self.profile
        changed.interestIds = [2]
        store.save(changed)
        let latest = Task { await vm.fetchRecommendation() }
        await controlled.requests.waitUntilRequested(2)
        await controlled.requests.finish(2)
        await latest.value
        await controlled.requests.finish(1)
        await previous.value
        await vm.fetchRecommendation()

        #expect(vm.myRecommendation.map(\.id) == [2])
        #expect(!vm.isRefreshingRecommendation)
        #expect(await controlled.requests.callCount == 2)
    }

    @Test("취소된 추천 요청은 캐시나 사용자 오류를 남기지 않는다")
    func cancelledRecommendation_isNotCached() async {
        let controlled = ControlledRecommendationUseCase()
        let (vm, _, _, _) = makeSUT(recommendationUseCase: controlled)
        let cancelled = Task { await vm.fetchRecommendation() }
        await controlled.requests.waitUntilRequested(1)
        cancelled.cancel()
        await controlled.requests.finish(1)
        await cancelled.value
        #expect(vm.myRecommendation.isEmpty)
        #expect(vm.currentError == nil)
        #expect(!vm.isRefreshingRecommendation)

        let retry = Task { await vm.fetchRecommendation() }
        await controlled.requests.waitUntilRequested(2)
        await controlled.requests.finish(2)
        await retry.value
        #expect(vm.myRecommendation.map(\.id) == [2])
    }

    @Test func resetFilters_clearsState() async {
        let (vm, _, _, _) = makeSUT()
        vm.day = [1, 2]
        vm.industry = [3]
        vm.orderOpt = .newest

        await vm.resetFilters()

        #expect(vm.day == nil)
        #expect(vm.industry == nil)
        #expect(vm.orderOpt == .popular)
        #expect(vm.shouldScrollToTop == true)
    }

    @Test func clearData_resetsAllState() {
        let (vm, _, _, _) = makeSUT()
        vm.allNewsletters = [ExploreBrand(brandId: 1, brandName: "A", imageUrl: nil, interests: [], isSubscribed: nil, shortDescription: "", subscriptionCount: 0)]
        vm.selectedTab = 1

        vm.clearData()

        #expect(vm.allNewsletters.isEmpty)
        #expect(vm.selectedTab == 0)
        #expect(vm.orderOpt == .popular)
    }
}

private struct ControlledRecommendationUseCase: FetchExploreRecommendationUseCase {
    let requests = RecommendationRequests()

    func execute() async throws -> ExploreRecommendedNewsletter {
        // 취소를 무시하고 늦게 반환하는 서버 응답도 재현한다.
        let id = await requests.start()
        let newsletter = ExploreNewsletterDetail(
            id: id, brandName: "추천 \(id)", firstDescription: "", secondDescription: "",
            publicationCycle: "", subscribeUrl: "", imageUrl: nil, createdAt: "", updatedAt: "",
            industries: [], interests: []
        )
        return ExploreRecommendedNewsletter(union: [newsletter], intersection: [newsletter])
    }
}

private actor RecommendationRequests {
    private(set) var callCount = 0
    private var pending: [Int: CheckedContinuation<Void, Never>] = [:]
    private var waiters: [Int: CheckedContinuation<Void, Never>] = [:]

    func start() async -> Int {
        callCount += 1
        let id = callCount
        await withCheckedContinuation { continuation in
            pending[id] = continuation
            waiters.removeValue(forKey: id)?.resume()
        }
        return id
    }

    func waitUntilRequested(_ id: Int) async {
        if pending[id] != nil { return }
        await withCheckedContinuation { waiters[id] = $0 }
    }

    func finish(_ id: Int) {
        pending.removeValue(forKey: id)?.resume()
    }
}
