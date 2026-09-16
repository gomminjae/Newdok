import Testing
import Foundation
import Synchronization
import HomeDomain
import HomeTesting
import Shared

@testable import Home

private final class StubHomeUserInfoStore: UserInfoStoreProtocol {
    private let user = Mutex<UserInfo?>(nil)
    func save(_ value: UserInfo) { user.withLock { $0 = value } }
    func load() -> UserInfo? { user.withLock { $0 } }
    func clear() { user.withLock { $0 = nil } }
    var hasProfile: Bool {
        guard let value = load() else { return false }
        return !value.nickname.isEmpty && value.industryId != nil && !value.interestIds.isEmpty
    }
}

private struct PublishedWidgetSummary: Equatable, Sendable {
    let totalCount: Int
    let unreadCount: Int
    let date: Date
}

private final class MockTodayWidgetSummaryPublisher: TodayWidgetSummaryPublishing, @unchecked Sendable {
    private let summaries = Mutex<[PublishedWidgetSummary]>([])
    private let clearCallCount = Mutex(0)

    var publishedSummaries: [PublishedWidgetSummary] {
        summaries.withLock { $0 }
    }

    var clearCount: Int {
        clearCallCount.withLock { $0 }
    }

    func publishTodaySummary(totalCount: Int, unreadCount: Int, date: Date) {
        summaries.withLock {
            $0.append(
                PublishedWidgetSummary(
                    totalCount: totalCount,
                    unreadCount: unreadCount,
                    date: date
                )
            )
        }
    }

    func clearTodaySummary() {
        clearCallCount.withLock { $0 += 1 }
    }
}

@Suite("HomeViewModel Tests")
@MainActor
struct HomeViewModelTests {
    private let fetchTodayArticles = MockFetchTodayArticlesUseCase()
    private let fetchMonthArticles = MockFetchMonthArticlesUseCase()
    private let fetchDayArticles = MockFetchDayArticlesUseCase()
    private let fetchNewsletters = MockFetchHomeNewslettersUseCase()
    private let decorateArticles = MockDecorateArticlesUseCase()
    private let refreshArticles = MockRefreshHomeArticlesUseCase()
    private let loadReadIds = MockLoadReadArticleIdsUseCase()
    private let saveReadIds = MockSaveReadArticleIdsUseCase()

    private func makeSUT(
        userInfoStore: UserInfoStoreProtocol = StubHomeUserInfoStore(),
        widgetSummaryPublisher: TodayWidgetSummaryPublishing? = nil
    ) -> HomeViewModel {
        let appState = AppState()
        appState.authState = .authenticated
        return HomeViewModel(
            fetchTodayArticles: fetchTodayArticles,
            fetchMonthArticles: fetchMonthArticles,
            fetchDayArticles: fetchDayArticles,
            fetchNewsletters: fetchNewsletters,
            decorateArticles: decorateArticles,
            refreshArticles: refreshArticles,
            loadReadIds: loadReadIds,
            saveReadIds: saveReadIds,
            extractArticleDays: ExtractArticleDaysUseCaseImpl(),
            mergeDayArticleSummary: MergeDayArticleSummaryUseCaseImpl(),
            appState: appState,
            userInfoStore: userInfoStore,
            widgetSummaryPublisher: widgetSummaryPublisher
        )
    }

    private static let sampleArticles = [
        HomeArticle(brandName: "B1", imageUrl: "", articleTitle: "T1", articleId: 10, status: .unread),
        HomeArticle(brandName: "B2", imageUrl: "", articleTitle: "T2", articleId: 20, status: .unread)
    ]

    private static let sampleNewsletter = HomeNewsletter(
        id: 1, brandName: "NL1", imageUrl: "", publicationCycle: "daily"
    )

    private func setupSuccessScenario() {
        let today = Calendar.current.component(.day, from: Date())
        fetchTodayArticles.result = .success(Self.sampleArticles)
        fetchDayArticles.result = .success(Self.sampleArticles)
        fetchNewsletters.result = .success([Self.sampleNewsletter])
        fetchMonthArticles.result = .success([
            HomeArticles(publishDate: today, hasArticles: true, totalCount: 2, unreadCount: 2)
        ])
    }

    @Test("loadToday fetches articles and newsletters")
    func loadTodaySuccess() async {
        setupSuccessScenario()

        let widgetPublisher = MockTodayWidgetSummaryPublisher()
        let sut = makeSUT(widgetSummaryPublisher: widgetPublisher)
        await sut.loadToday()

        #expect(sut.homeState == .articles)
        #expect(sut.filteredArticles.count == 2)
        #expect(sut.subscribedNewsletters.count == 1)
        #expect(fetchTodayArticles.executeCallCount == 1)
        #expect(fetchNewsletters.executeCallCount == 1)
        #expect(widgetPublisher.publishedSummaries.last?.totalCount == 2)
        #expect(widgetPublisher.publishedSummaries.last?.unreadCount == 2)
    }

    @Test("loadToday sets guest state for guest user")
    func loadTodayGuest() async {
        let appState = AppState()
        appState.authState = .guest
        let sut = HomeViewModel(
            fetchTodayArticles: fetchTodayArticles,
            fetchMonthArticles: fetchMonthArticles,
            fetchDayArticles: fetchDayArticles,
            fetchNewsletters: fetchNewsletters,
            decorateArticles: decorateArticles,
            refreshArticles: refreshArticles,
            loadReadIds: loadReadIds,
            saveReadIds: saveReadIds,
            extractArticleDays: ExtractArticleDaysUseCaseImpl(),
            mergeDayArticleSummary: MergeDayArticleSummaryUseCaseImpl(),
            appState: appState,
            userInfoStore: StubHomeUserInfoStore()
        )

        await sut.loadToday()

        #expect(sut.homeState == .guest)
        #expect(fetchTodayArticles.executeCallCount == 0)
    }

    @Test("loadToday handles failure gracefully")
    func loadTodayFailure() async {
        fetchTodayArticles.result = .failure(NSError(domain: "test", code: -1))
        fetchNewsletters.result = .success([])

        let widgetPublisher = MockTodayWidgetSummaryPublisher()
        let sut = makeSUT(widgetSummaryPublisher: widgetPublisher)
        await sut.loadToday()

        #expect(sut.filteredArticles.isEmpty)
        #expect(sut.homeState == .noSubscriptions)
    }

    @Test("markArticleAsRead updates read status and saves")
    func markArticleAsRead() async {
        setupSuccessScenario()
        decorateArticles.handler = { articles, readIds in
            articles.map { article in
                if readIds.contains(article.articleId) {
                    return HomeArticle(brandName: article.brandName, imageUrl: article.imageUrl, articleTitle: article.articleTitle, articleId: article.articleId, status: .read, publishDate: article.publishDate)
                }
                return article
            }
        }

        let widgetPublisher = MockTodayWidgetSummaryPublisher()
        let sut = makeSUT(widgetSummaryPublisher: widgetPublisher)
        await sut.loadToday()
        #expect(sut.filteredArticles.count == 2)

        await sut.markArticleAsRead(articleId: 10)

        #expect(saveReadIds.executeCallCount == 1)
        #expect(saveReadIds.savedIds?.contains(10) == true)
        let readArticle = sut.filteredArticles.first(where: { $0.articleId == 10 })
        #expect(readArticle?.status == .read)
        #expect(widgetPublisher.publishedSummaries.last?.unreadCount == 1)
    }

    @Test("과거 날짜의 읽음 처리는 오늘 위젯 요약을 변경하지 않는다")
    func markPastArticleDoesNotUpdateWidget() async {
        setupSuccessScenario()

        let widgetPublisher = MockTodayWidgetSummaryPublisher()
        let sut = makeSUT(widgetSummaryPublisher: widgetPublisher)
        await sut.loadToday()
        let publishCount = widgetPublisher.publishedSummaries.count

        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            Issue.record("어제 날짜 생성 실패")
            return
        }
        sut.selectedDate = yesterday
        await sut.markArticleAsRead(articleId: 10)

        #expect(widgetPublisher.publishedSummaries.count == publishCount)
    }

    @Test("resetForAuthChange clears all state")
    func resetForAuthChange() async {
        setupSuccessScenario()

        let widgetPublisher = MockTodayWidgetSummaryPublisher()
        let sut = makeSUT(widgetSummaryPublisher: widgetPublisher)
        await sut.loadToday()
        #expect(!sut.filteredArticles.isEmpty)

        await sut.resetForAuthChange()

        #expect(sut.filteredArticles.isEmpty)
        #expect(sut.subscribedNewsletters.isEmpty)
        #expect(sut.articlesByMonth.isEmpty)
        #expect(widgetPublisher.clearCount == 1)
    }

    @Test("shouldReloadToday returns true when not loaded")
    func shouldReloadTodayNotLoaded() async {
        let sut = makeSUT()
        let result = await sut.shouldReloadToday()
        #expect(result)
    }

    @Test("프로필 편집 후 같은 날 홈으로 돌아와도 다시 로딩한다")
    func shouldReloadTodayAfterProfileEdit() async {
        setupSuccessScenario()
        let store = StubHomeUserInfoStore()
        var profile = UserInfo(id: 1, nickname: "테스터", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interestIds: [1])
        store.save(profile)
        let sut = makeSUT(userInfoStore: store)
        await sut.loadToday()
        #expect(await sut.shouldReloadToday() == false)

        profile.interestIds = [2, 3]
        store.save(profile)
        #expect(await sut.shouldReloadToday())
        await sut.loadToday()

        #expect(fetchTodayArticles.executeCallCount == 2)
        #expect(fetchNewsletters.executeCallCount == 2)
        #expect(await sut.shouldReloadToday() == false)
    }

    @Test("프로필 재조회 실패 후에도 다음 홈 복귀에서 다시 시도한다")
    func profileReloadFailure_keepsReloadNeeded() async {
        setupSuccessScenario()
        let store = StubHomeUserInfoStore()
        var profile = UserInfo(id: 1, nickname: "테스터", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interestIds: [1])
        store.save(profile)
        let sut = makeSUT(userInfoStore: store)
        await sut.loadToday()

        profile.industryId = 2
        store.save(profile)
        fetchTodayArticles.result = .failure(NSError(domain: "test", code: -1))
        await sut.loadToday()

        #expect(await sut.shouldReloadToday())
    }

    @Test("refreshHighlights updates highlight counts")
    func refreshHighlights() async {
        setupSuccessScenario()

        let sut = makeSUT()
        await sut.loadToday()
        #expect(!sut.filteredArticles.isEmpty)

        decorateArticles.handler = { articles, _ in
            articles.map { $0.withHighlightCount($0.articleId == 10 ? 5 : 3) }
        }
        await sut.refreshHighlights()

        let article10 = sut.filteredArticles.first(where: { $0.articleId == 10 })
        let article20 = sut.filteredArticles.first(where: { $0.articleId == 20 })
        #expect(article10?.highlightCount == 5)
        #expect(article20?.highlightCount == 3)
    }

    @Test("noSubscriptions state when no newsletters and no articles")
    func noSubscriptionsState() async {
        fetchTodayArticles.result = .success([])
        fetchDayArticles.result = .success([])
        fetchNewsletters.result = .success([])
        fetchMonthArticles.result = .success([])

        let sut = makeSUT()
        await sut.loadToday()

        #expect(sut.homeState == .noSubscriptions)
    }
}
