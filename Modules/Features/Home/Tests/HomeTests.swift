import Testing
import Foundation
import HomeDomain
import HomeTesting
import Shared

@testable import Home

@Suite("HomeViewModel Tests")
@MainActor
struct HomeViewModelTests {
    private let fetchTodayArticles = MockFetchTodayArticlesUseCase()
    private let fetchMonthArticles = MockFetchMonthArticlesUseCase()
    private let fetchDayArticles = MockFetchDayArticlesUseCase()
    private let fetchNewsletters = MockFetchHomeNewslettersUseCase()
    private let fetchHighlightCounts = MockFetchHomeHighlightCountsUseCase()
    private let refreshArticles = MockRefreshHomeArticlesUseCase()
    private let loadReadIds = MockLoadReadArticleIdsUseCase()
    private let saveReadIds = MockSaveReadArticleIdsUseCase()

    private func makeSUT() -> HomeViewModel {
        let appState = AppState.shared
        appState.authState = .authenticated
        return HomeViewModel(
            fetchTodayArticles: fetchTodayArticles,
            fetchMonthArticles: fetchMonthArticles,
            fetchDayArticles: fetchDayArticles,
            fetchNewsletters: fetchNewsletters,
            fetchHighlightCounts: fetchHighlightCounts,
            refreshArticles: refreshArticles,
            loadReadIds: loadReadIds,
            saveReadIds: saveReadIds,
            appState: appState
        )
    }

    private static let sampleArticles = [
        HomeArticle(brandName: "B1", imageUrl: "", articleTitle: "T1", articleId: 10, status: "Unread"),
        HomeArticle(brandName: "B2", imageUrl: "", articleTitle: "T2", articleId: 20, status: "Unread")
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

        let sut = makeSUT()
        await sut.loadToday()

        #expect(sut.homeState == .articles)
        #expect(sut.filteredArticles.count == 2)
        #expect(sut.subscribedNewsletters.count == 1)
        #expect(fetchTodayArticles.executeCallCount == 1)
        #expect(fetchNewsletters.executeCallCount == 1)
    }

    @Test("loadToday sets guest state for guest user")
    func loadTodayGuest() async {
        let appState = AppState.shared
        appState.authState = .guest
        let sut = HomeViewModel(
            fetchTodayArticles: fetchTodayArticles,
            fetchMonthArticles: fetchMonthArticles,
            fetchDayArticles: fetchDayArticles,
            fetchNewsletters: fetchNewsletters,
            fetchHighlightCounts: fetchHighlightCounts,
            refreshArticles: refreshArticles,
            loadReadIds: loadReadIds,
            saveReadIds: saveReadIds,
            appState: appState
        )

        await sut.loadToday()

        #expect(sut.homeState == .guest)
        #expect(fetchTodayArticles.executeCallCount == 0)
    }

    @Test("loadToday handles failure gracefully")
    func loadTodayFailure() async {
        fetchTodayArticles.result = .failure(NSError(domain: "test", code: -1))
        fetchNewsletters.result = .success([])

        let sut = makeSUT()
        await sut.loadToday()

        #expect(sut.filteredArticles.isEmpty)
        #expect(sut.homeState == .noSubscriptions)
    }

    @Test("markArticleAsRead updates read status and saves")
    func markArticleAsRead() async {
        setupSuccessScenario()

        let sut = makeSUT()
        await sut.loadToday()
        #expect(sut.filteredArticles.count == 2)

        await sut.markArticleAsRead(articleId: 10)

        #expect(saveReadIds.executeCallCount == 1)
        #expect(saveReadIds.savedIds?.contains(10) == true)
        let readArticle = sut.filteredArticles.first(where: { $0.articleId == 10 })
        #expect(readArticle?.status.caseInsensitiveCompare("Read") == .orderedSame)
    }

    @Test("resetForAuthChange clears all state")
    func resetForAuthChange() async {
        setupSuccessScenario()

        let sut = makeSUT()
        await sut.loadToday()
        #expect(!sut.filteredArticles.isEmpty)

        await sut.resetForAuthChange()

        #expect(sut.filteredArticles.isEmpty)
        #expect(sut.subscribedNewsletters.isEmpty)
        #expect(sut.articlesByMonth.isEmpty)
    }

    @Test("shouldReloadToday returns true when not loaded")
    func shouldReloadTodayNotLoaded() async {
        let sut = makeSUT()
        let result = await sut.shouldReloadToday()
        #expect(result)
    }

    @Test("refreshHighlights updates highlight counts")
    func refreshHighlights() async {
        setupSuccessScenario()

        let sut = makeSUT()
        await sut.loadToday()
        #expect(!sut.filteredArticles.isEmpty)

        fetchHighlightCounts.result = [10: 5, 20: 3]
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
