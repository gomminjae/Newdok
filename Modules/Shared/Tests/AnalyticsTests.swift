import Foundation
import Testing
@testable import Shared

@Suite("분석 이벤트 계약")
struct AnalyticsTests {
    private let common = AnalyticsCommonProperties(environment: .production, build: "42", authState: .authenticated)

    @Test("승인된 23개 이벤트는 제한 안에서 직렬화된다")
    func eventContracts() throws {
        let flow = UUID(), attempt = UUID()
        let list = AnalyticsListContext(.homeArticles)
        let newsletter = AnalyticsNewsletter(id: "321", name: "공개 뉴스레터")
        let article = AnalyticsArticleContext(id: "123", kind: .current, source: .init(list: list))
        let events: [AnalyticsEvent] = [
            .screenViewed(.onboarding, step: .intro1, flowID: flow),
            .onboardingCompleted(flowID: flow, next: .login),
            .authAttemptStarted(flowID: flow, attemptID: attempt, method: .apple),
            .authAttemptFinished(flowID: flow, attemptID: attempt, method: .apple, outcome: .failed(.sdk)),
            .login(flowID: flow, attemptID: attempt, method: .apple),
            .signUp(flowID: flow, method: .apple), .profileSetupFinished(flowID: flow, outcome: .skipped),
            .guestStarted(flowID: flow), .contentSelected(.newsletter(newsletter), list: list),
            .contentStateViewed(surface: .home, state: .ready, list: list, date: .today),
            .searchStarted(list: .init(.searchNewsletters), source: .typed),
            .searchFinished(list: .init(.searchNewsletters), source: .popularKeyword, hasResults: false),
            .articleOpened(article), .articleRendered(article, newsletter: newsletter),
            .articleEngaged(article, newsletter: newsletter, activeVisibleMilliseconds: 30_000),
            .newsletterDetailViewed(newsletter, viewID: flow, source: .init(list: list), status: .initial),
            .subscribeStarted(newsletter, attemptID: attempt, viewID: flow, status: .initial),
            .subscribePageOpened(newsletter, attemptID: attempt), .subscribePageClosed(newsletter, attemptID: attempt),
            .homeActionSelected(state: .noSubscriptions, action: .exploreRecommended, date: .today),
            .operationFailed(.articleRender(article, newsletter), category: .rendering),
            .bookmarkChanged(article, newsletter: newsletter, action: .added), .highlightApplied(article, newsletter: newsletter)
        ]
        let payloads = try events.map { try #require($0.payload(common: common, from: .newsletterDetail)) }
        #expect(Set(payloads.map(\.name)).count == 23)
        #expect(payloads.allSatisfy { $0.parameters.count <= 13 })
        let forbidden = ["email", "user_id", "query", "search_text", "selected_text", "url", "error_message", "article_title"]
        #expect(payloads.allSatisfy { Set($0.parameters.keys).isDisjoint(with: forbidden) })
    }

    @Test("잘못된 식별자와 의미가 맞지 않는 이벤트를 전송하지 않는다")
    func invalidEvents() {
        let newsletter = AnalyticsNewsletter(id: "user@example.com")
        #expect(AnalyticsEvent.contentSelected(.newsletter(newsletter), list: .init(.exploreAll)).payload(common: common, from: .exploreAll) == nil)
        #expect(AnalyticsEvent.screenViewed(.home, step: .profile, flowID: nil).payload(common: common, from: .home) == nil)
        #expect(AnalyticsEvent.subscribeStarted(.init(id: "1"), attemptID: UUID(), viewID: nil, status: .initial).payload(common: common, from: .newsletterDetail) == nil)
        #expect(AnalyticsEvent.searchStarted(list: .init(.homeArticles), source: .typed).payload(common: common, from: .search) == nil)
        #expect(AnalyticsEvent.articleEngaged(.init(id: "1", kind: .current), newsletter: .init(id: "2"), activeVisibleMilliseconds: 29_999).payload(common: common, from: .home) == nil)
    }

    @Test("공개 표시 이름은 선택 값이고 과도한 길이는 생략한다")
    func optionalDisplayName() throws {
        let event = AnalyticsEvent.contentSelected(.newsletter(.init(id: "10", name: String(repeating: "가", count: 101))), list: .init(.exploreAll))
        let payload = try #require(event.payload(common: common, from: .exploreAll))
        #expect(payload.parameters["newsletter_id"] == .string("10"))
        #expect(payload.parameters["newsletter_name"] == nil)
    }

    @Test("백그라운드와 가려진 시간은 30초 읽기에서 제외하며 한 번만 확정한다")
    func activeReading() {
        let start = ContinuousClock.now
        var reading = ArticleReadingSession()
        reading.setActive(true, at: start)
        reading.setActive(false, at: start.advanced(by: .seconds(12)))
        #expect(reading.qualify(at: start.advanced(by: .seconds(100))) == nil)
        reading.setActive(true, at: start.advanced(by: .seconds(100)))
        #expect(reading.remaining(at: start.advanced(by: .seconds(110))) == .seconds(8))
        #expect(reading.qualify(at: start.advanced(by: .seconds(118))) == 30_000)
        #expect(reading.qualify(at: start.advanced(by: .seconds(120))) == nil)
    }

    @Test("인증 시도를 무효화하면 이전 콜백은 현재 시도가 아니다")
    @MainActor func authenticationAttemptOwnership() {
        let context = AuthAnalyticsContext()
        let old = context.beginAttempt(method: .apple)
        let current = context.beginAttempt(method: .kakao)
        context.finishAttempt(old)
        #expect(context.isCurrent(current))
        context.invalidate()
        #expect(!context.isCurrent(current))
    }
    @Test("외부 페이지의 중복 콜백과 닫힘은 같은 시도에서 한 번만 기록한다")
    @MainActor func subscriptionLifecycle() throws {
        let recorder = AnalyticsRecorder()
        let session = try #require(SubscriptionAnalyticsSession(newsletter: .init(id: "321"), url: "https://example.com/subscribe", client: recorder.client, from: .newsletterDetail, viewID: UUID(), status: .initial))
        session.pageFailed(URLError(.cancelled))
        session.pageFailed(URLError(.notConnectedToInternet))
        session.pageFailed(URLError(.timedOut))
        session.pageLoaded()
        session.pageLoaded()
        session.pageClosed()
        session.pageClosed()
        session.pageLoaded()
        #expect(recorder.payloads.map(\.name) == ["newsletter_subscribe_started", "operation_failed", "newsletter_subscribe_page_opened", "newsletter_subscribe_page_closed"])
        #expect(Set(recorder.payloads.compactMap { payload -> String? in
            guard case .string(let id) = payload.parameters["subscription_attempt_id"] else { return nil }; return id
        }).count == 1)
    }

    @Test("중지 재개와 잘못된 주소는 새 구독 시도가 아니다")
    @MainActor func invalidSubscription() {
        let recorder = AnalyticsRecorder()
        #expect(SubscriptionAnalyticsSession(newsletter: .init(id: "1"), url: "https://example.com", client: recorder.client, from: .newsletterDetail, viewID: UUID(), status: .paused) == nil)
        #expect(SubscriptionAnalyticsSession(newsletter: .init(id: "0"), url: "https://example.com", client: recorder.client, from: .signupCuration, status: .unknown) == nil)
        #expect(SubscriptionAnalyticsSession(newsletter: .init(id: "1"), url: "javascript:alert(1)", client: recorder.client, from: .signupCuration, status: .unknown) == nil)
        #expect(recorder.payloads.isEmpty)
    }

}

@MainActor private final class AnalyticsRecorder {
    var payloads: [AnalyticsPayload] = []
    var client: AnalyticsClient {
        AnalyticsClient { [self] event, source in
            if let payload = event.payload(common: .init(environment: .development, build: "1", authState: .guest), from: source) { payloads.append(payload) }
        }
    }
}
