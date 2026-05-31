import Testing
import Foundation
import BookmarkDomain
import Shared
@testable import Bookmark
@testable import BookmarkTesting

@Suite("BookmarkViewModel Tests")
@MainActor
struct BookmarkViewModelTests {

    private func makeSUT(
        articles: MockFetchBookmarkedArticlesUseCase = .init(),
        toggle: MockToggleBookmarkStatusUseCase = .init(),
        interests: MockFetchBookmarkedInterestsUseCase = .init()
    ) -> (vm: BookmarkViewModel, articles: MockFetchBookmarkedArticlesUseCase, interests: MockFetchBookmarkedInterestsUseCase) {
        let vm = BookmarkViewModel(
            fetchArticlesUseCase: articles,
            toggleBookmarkUseCase: toggle,
            fetchInterestsUseCase: interests
        )
        return (vm, articles, interests)
    }

    // MARK: - fetchUserInterests

    @Test("관심사 목록 로드 성공")
    func fetchUserInterests_success() async {
        let mock = MockFetchBookmarkedInterestsUseCase()
        mock.result = .success([
            BookmarkInterest(id: 1, name: "경제"),
            BookmarkInterest(id: 2, name: "테크")
        ])
        let (vm, _, _) = makeSUT(interests: mock)

        await vm.fetchUserInterests()

        #expect(vm.interests.count == 2)
        #expect(mock.executeCallCount == 1)
    }

    @Test("관심사 로드 실패 시 에러 처리")
    func fetchUserInterests_failure() async {
        let mock = MockFetchBookmarkedInterestsUseCase()
        mock.result = .failure(NSError(domain: "test", code: -1))
        let (vm, _, _) = makeSUT(interests: mock)

        await vm.fetchUserInterests()

        #expect(vm.interests.isEmpty)
        #expect(vm.currentError != nil)
    }

    // MARK: - fetchUserBookmarks

    @Test("북마크 목록 로드 성공")
    func fetchUserBookmarks_success() async {
        let mock = MockFetchBookmarkedArticlesUseCase()
        mock.result = .success(BookmarkedArticles(totalAmount: 3, bookmarkForMonth: []))
        let (vm, _, _) = makeSUT(articles: mock)

        await vm.fetchUserBookmarks()

        #expect(vm.bookmarks?.totalAmount == 3)
        #expect(mock.executedSortBy == .bookmarkDate)
    }

    @Test("정렬 기준 변경 후 로드")
    func fetchUserBookmarks_sortOrder() async {
        let mock = MockFetchBookmarkedArticlesUseCase()
        mock.result = .success(BookmarkedArticles(totalAmount: 0, bookmarkForMonth: []))
        let (vm, _, _) = makeSUT(articles: mock)
        vm.sortOrder = .articleDateDesc

        await vm.fetchUserBookmarks()

        #expect(mock.executedSortBy == .articleDateDesc)
    }

    @Test("북마크 로드 실패 시 에러 처리")
    func fetchUserBookmarks_failure() async {
        let mock = MockFetchBookmarkedArticlesUseCase()
        mock.result = .failure(NSError(domain: "test", code: -1))
        let (vm, _, _) = makeSUT(articles: mock)

        await vm.fetchUserBookmarks()

        #expect(vm.bookmarks == nil)
        #expect(vm.currentError != nil)
    }

    // MARK: - clearData

    @Test("데이터 초기화")
    func clearData() async {
        let articlesMock = MockFetchBookmarkedArticlesUseCase()
        articlesMock.result = .success(BookmarkedArticles(totalAmount: 5, bookmarkForMonth: []))
        let interestsMock = MockFetchBookmarkedInterestsUseCase()
        interestsMock.result = .success([BookmarkInterest(id: 1, name: "경제")])
        let (vm, _, _) = makeSUT(articles: articlesMock, interests: interestsMock)

        await vm.fetchUserInterests()
        await vm.fetchUserBookmarks()
        vm.clearData()

        #expect(vm.interest.isEmpty)
        #expect(vm.interests.isEmpty)
        #expect(vm.bookmarks == nil)
        #expect(vm.sortOrder == .bookmarkDate)
    }
}
