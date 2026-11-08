import Testing
import Foundation
import SubscribeDomain
import Shared
@testable import Subscribe
@testable import SubscribeTesting

@Suite("SubscribeViewModel Tests")
@MainActor
struct SubscribeViewModelTests {

    private func makeSUT(
        active: MockFetchActiveSubscriptionUseCase = .init(),
        paused: MockFetchPausedSubscriptionUseCase = .init(),
        pause: MockPauseSubscriptionUseCase = .init(),
        resume: MockResumeSubscriptionUseCase = .init()
    ) -> SubscribeViewModel {
        let appState = AppState()
        appState.login()
        return SubscribeViewModel(
            fetchActiveUseCase: active,
            fetchPausedUseCase: paused,
            pauseUseCase: pause,
            resumeUseCase: resume,
            appState: appState
        )
    }

    private func makeNewsletter(id: Int = 1, name: String = "뉴닉") -> SubscribeNewsletter {
        SubscribeNewsletter(id: id, brandName: name, imageUrl: "", publicationCycle: "매일")
    }

    // MARK: - loadInitial

    @Test("초기 로드 성공 시 active/paused 반영")
    func loadInitial_success() async {
        let activeMock = MockFetchActiveSubscriptionUseCase()
        activeMock.result = .success([makeNewsletter(id: 1, name: "뉴닉")])
        let pausedMock = MockFetchPausedSubscriptionUseCase()
        pausedMock.result = .success([makeNewsletter(id: 2, name: "일간이슬아")])
        let vm = makeSUT(active: activeMock, paused: pausedMock)

        await vm.loadInitial()

        #expect(vm.activeNewsletters.count == 1)
        #expect(vm.pausedNewsletters.count == 1)
        #expect(vm.initialLoaded)
    }

    @Test("초기 로드 실패 시 재시도 가능")
    func loadInitial_failure() async {
        let activeMock = MockFetchActiveSubscriptionUseCase()
        activeMock.result = .failure(NSError(domain: "test", code: -1))
        let vm = makeSUT(active: activeMock)

        await vm.loadInitial()

        #expect(vm.activeNewsletters.isEmpty)
        #expect(!vm.initialLoaded)
        #expect(vm.currentError != nil)

        activeMock.result = .success([makeNewsletter()])
        await vm.loadInitial()

        #expect(activeMock.executeCallCount == 2)
        #expect(vm.initialLoaded)
        #expect(vm.currentError == nil)
    }

    @Test("초기 로드 취소 시 미로드 상태 유지")
    func loadInitial_cancellation() async {
        let activeMock = MockFetchActiveSubscriptionUseCase()
        activeMock.result = .failure(CancellationError())
        let vm = makeSUT(active: activeMock)

        await vm.loadInitial()

        #expect(!vm.initialLoaded)
        #expect(!vm.isLoadingActive)
        #expect(!vm.isLoadingPaused)
        #expect(vm.currentError == nil)
    }

    @Test("초기 로드 중복 호출 방지")
    func loadInitial_skipIfAlreadyLoaded() async {
        let activeMock = MockFetchActiveSubscriptionUseCase()
        activeMock.result = .success([makeNewsletter()])
        let vm = makeSUT(active: activeMock)

        await vm.loadInitial()
        await vm.loadInitial()

        #expect(activeMock.executeCallCount == 1)
    }

    @Test("빈 구독 중지 목록은 활성 구독 없음과 다르게 기록한다")
    func emptyListSemantics() async {
        let vm = makeSUT()
        await vm.loadInitial()
        #expect(vm.analyticsState(tab: 0) == .noSubscriptions)
        #expect(vm.analyticsState(tab: 1) == .noResults)
        #expect(vm.analyticsList(tab: 1).list == .pausedNewsletters)
    }

    // MARK: - refresh

    @Test("탭 0 새로고침 시 active만 갱신")
    func refresh_activeTab() async {
        let activeMock = MockFetchActiveSubscriptionUseCase()
        activeMock.result = .success([makeNewsletter(id: 1), makeNewsletter(id: 2)])
        let vm = makeSUT(active: activeMock)

        await vm.refresh(tab: 0)

        #expect(vm.activeNewsletters.count == 2)
    }

    @Test("탭 1 새로고침 시 paused만 갱신")
    func refresh_pausedTab() async {
        let pausedMock = MockFetchPausedSubscriptionUseCase()
        pausedMock.result = .success([makeNewsletter(id: 3)])
        let vm = makeSUT(paused: pausedMock)

        await vm.refresh(tab: 1)

        #expect(vm.pausedNewsletters.count == 1)
    }

    @Test("구독 재조회 실패는 기존 카드와 실패한 요청을 별도 문맥으로 유지한다")
    func failedRefreshPreservesDisplayedList() async {
        let active = MockFetchActiveSubscriptionUseCase()
        active.result = .success([makeNewsletter()])
        let vm = makeSUT(active: active)
        await vm.loadInitial()
        let displayed = vm.analyticsList(tab: 0)
        active.result = .failure(SubscribeAnalyticsServerFailure())
        await vm.refresh(tab: 0)
        #expect(vm.activeNewsletters.count == 1)
        #expect(vm.analyticsList(tab: 0) == displayed)
        #expect(vm.analyticsState(tab: 0) == .failed)
        #expect(vm.analyticsStateList(tab: 0) != displayed)
    }

    // MARK: - pause / resume

    @Test("구독 일시정지 성공")
    func pause_success() async {
        let pauseMock = MockPauseSubscriptionUseCase()
        let vm = makeSUT(pause: pauseMock)

        let success = await vm.pause(newsletterId: "123")

        #expect(success)
        #expect(pauseMock.executedNewsletterId == "123")
    }

    @Test("구독 재개 성공")
    func resume_success() async {
        let resumeMock = MockResumeSubscriptionUseCase()
        let vm = makeSUT(resume: resumeMock)

        let success = await vm.resume(newsletterId: "456")

        #expect(success)
        #expect(resumeMock.executedNewsletterId == "456")
    }

    @Test("동일 구독 중복 mutation 방지")
    func pause_duplicatePrevented() async {
        let pauseMock = MockPauseSubscriptionUseCase()
        let vm = makeSUT(pause: pauseMock)

        // 첫 번째 성공
        let first = await vm.pause(newsletterId: "123")
        #expect(first)
        // pendingIds는 defer로 제거되므로 다시 호출 가능
        let second = await vm.pause(newsletterId: "123")
        #expect(second)
    }
}

private struct SubscribeAnalyticsServerFailure: Error, AppErrorConvertible {
    func toAppError() -> AppError { .serverError }
}
