import Testing
import Foundation
import Shared
@testable import Detail
@testable import DetailTesting
@testable import DetailDomain

// MARK: - Test Helpers

private final class StubPopupPreference: SubscribePopupStorable {
    var shouldShow: Bool = true
    private(set) var hideForTodayCalled = false
    func hideForToday() { hideForTodayCalled = true }
}

private final class StubUserInfoStore: UserInfoStoreProtocol, @unchecked Sendable {
    var storedUser: UserInfo?
    func save(_ user: UserInfo) { storedUser = user }
    func load() -> UserInfo? { storedUser }
    func clear() { storedUser = nil }
    var hasProfile: Bool { storedUser?.industryId != nil }
}

private extension UserInfo {
    static let stub = UserInfo(
        id: 1,
        subscribeEmail: "test@example.com", nickname: "테스터",
        birthYear: "2000", gender: "M", createdAt: "2025-01-01",
        industryId: 1, interestIds: []
    )
}

@Suite("ArticleDetailViewModel Tests")
@MainActor
struct ArticleDetailViewModelTests {
    private func makeSUT(id: String = "1") -> (
        vm: ArticleDetailViewModel,
        fetchDetail: MockFetchArticleDetailUseCase,
        toggleBookmark: MockToggleArticleBookmarkUseCase,
        highlightRepo: MockDetailHighlightRepository
    ) {
        let fetchDetail = MockFetchArticleDetailUseCase()
        let toggleBookmark = MockToggleArticleBookmarkUseCase()
        let highlightRepo = MockDetailHighlightRepository()
        let vm = ArticleDetailViewModel(
            id: id,
            fetchDetailUseCase: fetchDetail,
            toggleBookmarkUseCase: toggleBookmark,
            highlightRepository: highlightRepo
        )
        return (vm, fetchDetail, toggleBookmark, highlightRepo)
    }

    @Test func fetch_success() async {
        let (vm, fetchDetail, _, _) = makeSUT(id: "42")
        let detail = DetailArticleDetail(
            articleTitle: "테스트 제목",
            articleId: 42,
            date: "2025-01-01",
            brandId: 1,
            brandName: "브랜드",
            articleHTML: "<p>내용</p>",
            brandImageUrl: "",
            isBookmarked: false
        )
        fetchDetail.result = .success(DetailArticleDetailResult(detail: detail, articleId: "42"))

        await vm.fetch()

        #expect(fetchDetail.executedArticleId == "42")
        #expect(vm.detail?.articleTitle == "테스트 제목")
        #expect(vm.detail?.isBookmarked == false)
    }

    @Test func fetch_failure() async {
        let (vm, fetchDetail, _, _) = makeSUT()
        fetchDetail.result = .failure(NSError(domain: "test", code: -1))

        await vm.fetch()

        #expect(vm.detail == nil)
        #expect(vm.currentError != nil)
    }

    @Test func bookmark_togglesState() async {
        let (vm, _, toggleBookmark, _) = makeSUT()
        vm.detail = DetailArticleDetail(
            articleTitle: "제목",
            articleId: 1,
            date: "2025-01-01",
            brandId: 1,
            brandName: "브랜드",
            articleHTML: "",
            brandImageUrl: "",
            isBookmarked: false
        )

        await vm.bookmark()

        #expect(toggleBookmark.executedArticleId == "1")
        #expect(vm.detail?.isBookmarked == true)
    }

    @Test func bookmark_failure_doesNotToggle() async {
        let (vm, _, toggleBookmark, _) = makeSUT()
        toggleBookmark.result = .failure(NSError(domain: "test", code: -1))
        vm.detail = DetailArticleDetail(
            articleTitle: "제목",
            articleId: 1,
            date: "2025-01-01",
            brandId: 1,
            brandName: "브랜드",
            articleHTML: "",
            brandImageUrl: "",
            isBookmarked: false
        )

        await vm.bookmark()

        #expect(vm.detail?.isBookmarked == false)
    }

    @Test func highlightsJSON_returnsCorrectFormat() async {
        let (vm, fetchDetail, _, highlightRepo) = makeSUT()
        let detail = DetailArticleDetail(
            articleTitle: "제목",
            articleId: 1,
            date: "2025-01-01",
            brandId: 1,
            brandName: "브랜드",
            articleHTML: "",
            brandImageUrl: "",
            isBookmarked: false
        )
        fetchDetail.result = .success(DetailArticleDetailResult(detail: detail, articleId: "1"))
        highlightRepo.highlightsResult = [
            DetailHighlight(id: UUID(), articleId: "1", articleTitle: "제목", brandName: "브랜드", selectedText: "하이라이트", style: .yellow, textOffset: 0, createdAt: Date())
        ]

        await vm.fetch()

        let json = vm.highlightsJSON()
        #expect(json.count == 1)
        #expect(json.first?["text"] == "하이라이트")
        #expect(json.first?["type"] == "yellow")
    }
}

// MARK: - BrandDetailViewModel Tests

@Suite("BrandDetailViewModel Tests")
@MainActor
struct BrandDetailViewModelTests {
    private func makeSUT(
        id: String = "1",
        brandResult: Result<DetailBrandDetail, Error>? = nil,
        guestBrandResult: Result<DetailBrandDetail, Error>? = nil,
        userInfo: UserInfo? = .stub
    ) -> (
        vm: BrandDetailViewModel,
        repo: MockDetailBrandRepository,
        popup: StubPopupPreference,
        userStore: StubUserInfoStore
    ) {
        var repo: MockDetailBrandRepository
        if let brandResult, let guestBrandResult {
            repo = MockDetailBrandRepository(brandResult: brandResult, guestBrandResult: guestBrandResult)
        } else if let brandResult {
            repo = MockDetailBrandRepository(brandResult: brandResult)
        } else if let guestBrandResult {
            repo = MockDetailBrandRepository(guestBrandResult: guestBrandResult)
        } else {
            repo = MockDetailBrandRepository()
        }
        let popup = StubPopupPreference()
        let userStore = StubUserInfoStore()
        userStore.storedUser = userInfo
        let vm = BrandDetailViewModel(
            id: id,
            brandRepository: repo,
            popupPreference: popup,
            userInfoStore: userStore
        )
        return (vm, repo, popup, userStore)
    }

    // MARK: - fetch

    @Test("fetch 성공 시 detail 반영")
    func fetch_success() async {
        let (vm, repo, _, _) = makeSUT(id: "1")

        await vm.fetch()

        #expect(repo.fetchBrandCallCount == 1)
        #expect(vm.detail != nil)
        #expect(vm.detail?.brandName == "테스트 브랜드")
    }

    @Test("fetch 실패 시 에러 처리")
    func fetch_failure() async {
        let (vm, _, _, _) = makeSUT(
            brandResult: .failure(NSError(domain: "test", code: -1))
        )

        await vm.fetch()

        #expect(vm.detail == nil)
        #expect(vm.currentError != nil)
    }

    // MARK: - guestFetch

    @Test("guestFetch 성공 시 detail 반영")
    func guestFetch_success() async {
        let (vm, repo, _, _) = makeSUT()

        await vm.guestFetch()

        #expect(repo.fetchGuestBrandCallCount == 1)
        #expect(vm.detail != nil)
    }

    @Test("guestFetch 실패 시 에러 처리")
    func guestFetch_failure() async {
        let (vm, _, _, _) = makeSUT(
            guestBrandResult: .failure(NSError(domain: "test", code: -1))
        )

        await vm.guestFetch()

        #expect(vm.detail == nil)
        #expect(vm.currentError != nil)
    }

    // MARK: - pause

    @Test("pause 성공")
    func pause_success() async {
        let (vm, repo, _, _) = makeSUT(id: "42")

        let result = await vm.pause()

        #expect(result == true)
        #expect(repo.pausedNewsletterId == "42")
    }

    @Test("pause 실패 — DetailError 시 userMessage 설정")
    func pause_detailError() async {
        let (vm, repo, _, _) = makeSUT()
        repo.pauseResult = .failure(DetailError.alreadyPaused)

        let result = await vm.pause()

        #expect(result == false)
        #expect(vm.currentError != nil)
    }

    @Test("pause 실패 — 일반 에러")
    func pause_genericError() async {
        let (vm, repo, _, _) = makeSUT()
        repo.pauseResult = .failure(NSError(domain: "test", code: -1))

        let result = await vm.pause()

        #expect(result == false)
    }

    @Test("pause 중복 호출 방지")
    func pause_duplicatePrevented() async {
        let (vm, _, _, _) = makeSUT()
        vm.isSubscriptionMutating = true

        let result = await vm.pause()

        #expect(result == false)
    }

    // MARK: - resume

    @Test("resume 성공")
    func resume_success() async {
        let (vm, repo, _, _) = makeSUT(id: "99")

        let result = await vm.resume()

        #expect(result == true)
        #expect(repo.resumedNewsletterId == "99")
    }

    @Test("resume 실패 — DetailError 시 userMessage 설정")
    func resume_detailError() async {
        let (vm, repo, _, _) = makeSUT()
        repo.resumeResult = .failure(DetailError.alreadyActive)

        let result = await vm.resume()

        #expect(result == false)
        #expect(vm.currentError != nil)
    }

    @Test("resume 실패 — 일반 에러")
    func resume_genericError() async {
        let (vm, repo, _, _) = makeSUT()
        repo.resumeResult = .failure(NSError(domain: "test", code: -1))

        let result = await vm.resume()

        #expect(result == false)
    }

    @Test("resume 중복 호출 방지")
    func resume_duplicatePrevented() async {
        let (vm, _, _, _) = makeSUT()
        vm.isSubscriptionMutating = true

        let result = await vm.resume()

        #expect(result == false)
    }

    // MARK: - Computed properties

    @Test("subscribeEmail은 userInfoStore에서 로드")
    func subscribeEmail() {
        let (vm, _, _, _) = makeSUT()

        #expect(vm.subscribeEmail == "test@example.com")
    }

    @Test("userNickname은 userInfoStore에서 로드")
    func userNickname() {
        let (vm, _, _, _) = makeSUT()

        #expect(vm.userNickname == "테스터")
    }

    @Test("userInfoStore가 비어있으면 빈 문자열")
    func emptyUserInfo() {
        let (vm, _, _, _) = makeSUT(userInfo: nil)

        #expect(vm.subscribeEmail == "")
        #expect(vm.userNickname == "")
    }

    // MARK: - Popup preference

    @Test("shouldShowSubscribeStatePopup 위임")
    func shouldShowPopup() {
        let (vm, _, popup, _) = makeSUT()
        popup.shouldShow = false

        #expect(vm.shouldShowSubscribeStatePopup == false)
    }

    @Test("hideSubscribeStatePopupForToday 위임")
    func hidePopupForToday() {
        let (vm, _, popup, _) = makeSUT()

        vm.hideSubscribeStatePopupForToday()

        #expect(popup.hideForTodayCalled == true)
    }
}
