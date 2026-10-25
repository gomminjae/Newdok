import Testing
@testable import Shared

@Suite("공통 선택 목록 저장소")
@MainActor
struct SelectableItemStoreTests {
    private static let options = SelectableOptions(
        interests: [.init(id: 1, name: "경제")],
        industries: [.init(id: 5, name: "IT")],
        days: [.init(id: 1, name: "월요일")]
    )

    @Test("초기화만으로는 조회하지 않고 성공한 목록은 재사용한다")
    func lazyLoadAndCache() async throws {
        let fetcher = StubOptionsFetcher(result: .success(Self.options))
        let store = SelectableItemStore(fetchOptionsUseCase: fetcher)
        #expect(store.loadState == .idle)
        #expect(fetcher.requestCount == 0)

        try await store.loadIfNeeded()
        try await store.loadIfNeeded()

        #expect(store.loadState == .loaded)
        #expect(store.interests == Self.options.interests)
        #expect(store.list(for: .industry) == Self.options.industries)
        #expect(store.name(for: 1, in: .day) == "월요일")
        #expect(fetcher.requestCount == 1)
    }

    @Test("실패 후에는 다시 조회할 수 있다")
    func retryAfterFailure() async throws {
        let fetcher = StubOptionsFetcher(result: .failure(OptionsTestError.failed))
        let store = SelectableItemStore(fetchOptionsUseCase: fetcher)
        await #expect(throws: OptionsTestError.self) { try await store.loadIfNeeded() }
        #expect(store.loadState == .failed)
        #expect(store.interests.isEmpty)

        fetcher.result = .success(Self.options)
        try await store.loadIfNeeded()
        #expect(store.loadState == .loaded)
        #expect(fetcher.requestCount == 2)
    }

    @Test("정상 빈 목록은 실패나 미조회가 아니다")
    func emptySuccess() async throws {
        let fetcher = StubOptionsFetcher(result: .success(.init(interests: [], industries: [], days: [])))
        let store = SelectableItemStore(fetchOptionsUseCase: fetcher)
        try await store.loadIfNeeded()

        #expect(store.loadState == .loaded)
        #expect(store.interests.isEmpty)
        #expect(store.industries.isEmpty)
        #expect(store.days.isEmpty)
    }

    @Test("조회 취소는 실패 UI로 표시하지 않는다")
    func cancelledFetch() async {
        let fetcher = StubOptionsFetcher(result: .failure(CancellationError()))
        let store = SelectableItemStore(fetchOptionsUseCase: fetcher)
        await #expect(throws: CancellationError.self) { try await store.loadIfNeeded() }
        #expect(store.loadState == .idle)
        #expect(store.interests.isEmpty)
    }

    @Test("중복 ID나 빈 이름은 부분 반영하지 않는다", arguments: [
        SelectableOptions(interests: [.init(id: 1, name: "A"), .init(id: 1, name: "B")], industries: [], days: []),
        SelectableOptions(interests: [], industries: [.init(id: 1, name: " \n ")], days: [])
    ])
    func invalidOptions(options: SelectableOptions) async {
        let fetcher = StubOptionsFetcher(result: .success(options))
        let store = SelectableItemStore(fetchOptionsUseCase: fetcher)
        await #expect(throws: AppError.self) { try await store.loadIfNeeded() }
        #expect(store.loadState == .failed)
        #expect(store.interests.isEmpty)
        #expect(store.industries.isEmpty)
    }
}

private enum OptionsTestError: Error { case failed }

@MainActor
private final class StubOptionsFetcher: FetchSelectableOptionsUseCase {
    var result: Result<SelectableOptions, Error>
    private(set) var requestCount = 0

    init(result: Result<SelectableOptions, Error>) { self.result = result }

    func execute() async throws -> SelectableOptions {
        requestCount += 1
        return try result.get()
    }
}
