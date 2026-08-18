import Testing
import Foundation
import SearchDomain
import Shared
@testable import Search
@testable import SearchTesting

@Suite("SearchViewModel Tests")
@MainActor
struct SearchViewModelTests {

    private func makeSUT(
        search: MockSearchNewslettersUseCase = .init(),
        popular: MockFetchPopularKeywordsUseCase = .init()
    ) -> (vm: SearchViewModel, search: MockSearchNewslettersUseCase, popular: MockFetchPopularKeywordsUseCase) {
        let vm = SearchViewModel(
            searchNewslettersUseCase: search,
            fetchPopularKeywordsUseCase: popular
        )
        return (vm, search, popular)
    }

    // MARK: - searchNewsletters

    @Test("검색 성공 시 결과 반영")
    func searchNewsletters_success() async {
        let mock = MockSearchNewslettersUseCase()
        mock.result = .success([
            SearchedNewsletter(id: "1", brandName: "뉴닉", firstDescription: "뉴스", imageUrl: "")
        ])
        let (vm, _, _) = makeSUT(search: mock)
        vm.searchText = "뉴닉"

        await vm.searchNewsletters()

        #expect(vm.searchResults.count == 1)
        #expect(vm.searchResults.first?.brandName == "뉴닉")
        #expect(mock.executedBrandName == "뉴닉")
        #expect(vm.searchError == nil)
    }

    @Test("검색 실패 시 에러 메시지 설정")
    func searchNewsletters_failure() async {
        let mock = MockSearchNewslettersUseCase()
        mock.result = .failure(NSError(domain: "test", code: -1))
        let (vm, _, _) = makeSUT(search: mock)
        vm.searchText = "테스트"

        await vm.searchNewsletters()

        #expect(vm.searchResults.isEmpty)
        #expect(vm.searchError != nil)
    }

    @Test("빈 검색어는 검색하지 않음")
    func searchNewsletters_emptyQuery() async {
        let mock = MockSearchNewslettersUseCase()
        let (vm, _, _) = makeSUT(search: mock)
        vm.searchText = ""

        await vm.searchNewsletters()

        #expect(mock.executedBrandName == nil)
        #expect(vm.searchResults.isEmpty)
    }

    @Test("늦게 끝난 이전 검색 결과를 무시")
    func searchNewsletters_latestRequestWins() async {
        let controlled = ControlledSearchUseCase()
        let vm = SearchViewModel(
            searchNewslettersUseCase: controlled,
            fetchPopularKeywordsUseCase: MockFetchPopularKeywordsUseCase()
        )

        vm.searchText = "이전"
        let previousTask = Task { await vm.searchNewsletters() }
        await controlled.waitUntilRequested("이전")

        vm.searchText = "최신"
        let latestTask = Task { await vm.searchNewsletters() }
        await controlled.waitUntilRequested("최신")

        await controlled.succeed(
            "최신",
            with: [SearchedNewsletter(id: "new", brandName: "최신", firstDescription: "", imageUrl: "")]
        )
        await latestTask.value

        await controlled.succeed(
            "이전",
            with: [SearchedNewsletter(id: "old", brandName: "이전", firstDescription: "", imageUrl: "")]
        )
        await previousTask.value

        #expect(vm.searchResults.map(\.id) == ["new"])
        #expect(vm.isLoading == false)
    }

    // MARK: - loadPopularKeywords

    @Test("인기 키워드 로드 성공")
    func loadPopularKeywords_success() async {
        let mock = MockFetchPopularKeywordsUseCase()
        mock.result = .success(
            PopularKeywordList(updatedDate: "2026-05-19", keywords: [
                PopularKeyword(rank: 1, keyword: "경제"),
                PopularKeyword(rank: 2, keyword: "테크")
            ])
        )
        let (vm, _, _) = makeSUT(popular: mock)

        await vm.loadPopularKeywords()

        #expect(vm.popularKeywords?.keywords.count == 2)
        #expect(mock.executeCallCount == 1)
    }

    @Test("인기 키워드 중복 로드 방지")
    func loadPopularKeywords_skipIfAlreadyLoaded() async {
        let mock = MockFetchPopularKeywordsUseCase()
        mock.result = .success(
            PopularKeywordList(updatedDate: "2026-05-19", keywords: [
                PopularKeyword(rank: 1, keyword: "경제")
            ])
        )
        let (vm, _, _) = makeSUT(popular: mock)

        await vm.loadPopularKeywords()
        await vm.loadPopularKeywords()

        #expect(mock.executeCallCount == 1)
    }

    @Test("force=true면 재로드")
    func loadPopularKeywords_forceReload() async {
        let mock = MockFetchPopularKeywordsUseCase()
        mock.result = .success(
            PopularKeywordList(updatedDate: "2026-05-19", keywords: [])
        )
        let (vm, _, _) = makeSUT(popular: mock)

        await vm.loadPopularKeywords()
        await vm.loadPopularKeywords(force: true)

        #expect(mock.executeCallCount == 2)
    }

    @Test("인기 키워드 로드 실패 시 에러 메시지")
    func loadPopularKeywords_failure() async {
        let mock = MockFetchPopularKeywordsUseCase()
        mock.result = .failure(NSError(domain: "test", code: -1))
        let (vm, _, _) = makeSUT(popular: mock)

        await vm.loadPopularKeywords()

        #expect(vm.popularKeywords == nil)
        #expect(vm.popularError != nil)
    }

    // MARK: - clearSearchResults

    @Test("검색 결과 초기화")
    func clearSearchResults() async {
        let mock = MockSearchNewslettersUseCase()
        mock.result = .success([
            SearchedNewsletter(id: "1", brandName: "뉴닉", firstDescription: "", imageUrl: "")
        ])
        let (vm, _, _) = makeSUT(search: mock)
        vm.searchText = "뉴닉"
        await vm.searchNewsletters()

        vm.clearSearchResults()

        #expect(vm.searchText.isEmpty)
        #expect(vm.searchResults.isEmpty)
        #expect(vm.searchError == nil)
    }

    // MARK: - selectPopularKeyword

    @Test("인기 키워드 선택 시 검색 실행")
    func selectPopularKeyword() async {
        let mock = MockSearchNewslettersUseCase()
        mock.result = .success([
            SearchedNewsletter(id: "1", brandName: "경제", firstDescription: "", imageUrl: "")
        ])
        let (vm, _, _) = makeSUT(search: mock)

        await vm.selectPopularKeyword("경제")

        #expect(vm.searchText == "경제")
        #expect(mock.executedBrandName == "경제")
        #expect(vm.searchResults.count == 1)
    }
}

private actor ControlledSearchUseCase: SearchNewslettersUseCase {
    private var requests: [String: CheckedContinuation<[SearchedNewsletter], Error>] = [:]
    private var requestWaiters: [String: CheckedContinuation<Void, Never>] = [:]

    func execute(brandName: String) async throws -> [SearchedNewsletter] {
        try await withCheckedThrowingContinuation { continuation in
            requests[brandName] = continuation
            requestWaiters.removeValue(forKey: brandName)?.resume()
        }
    }

    func waitUntilRequested(_ brandName: String) async {
        if requests[brandName] != nil { return }
        await withCheckedContinuation { requestWaiters[brandName] = $0 }
    }

    func succeed(_ brandName: String, with results: [SearchedNewsletter]) {
        requests.removeValue(forKey: brandName)?.resume(returning: results)
    }
}
