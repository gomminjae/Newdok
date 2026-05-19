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
        #expect(vm.errorMessage == nil)
    }

    @Test("검색 실패 시 에러 메시지 설정")
    func searchNewsletters_failure() async {
        let mock = MockSearchNewslettersUseCase()
        mock.result = .failure(NSError(domain: "test", code: -1))
        let (vm, _, _) = makeSUT(search: mock)
        vm.searchText = "테스트"

        await vm.searchNewsletters()

        #expect(vm.searchResults.isEmpty)
        #expect(vm.errorMessage != nil)
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
        #expect(vm.popularErrorMessage != nil)
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
        #expect(vm.errorMessage == nil)
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
