import Foundation

public enum AnalyticsOperation: Sendable {
    case signup(flowID: UUID), profile(flowID: UUID)
    case list(AnalyticsListContext)
    case newsletter(id: String, viewID: UUID)
    case articleLoad(AnalyticsArticleContext)
    case articleRender(AnalyticsArticleContext, AnalyticsNewsletter)
    case subscribePage(AnalyticsNewsletter, attemptID: UUID)
    case bookmark(AnalyticsArticleContext, AnalyticsNewsletter)
    case highlight(AnalyticsArticleContext, AnalyticsNewsletter)
}

public enum AnalyticsEvent: Sendable {
    case screenViewed(AnalyticsScreen, step: AnalyticsStep?, flowID: UUID?)
    case onboardingCompleted(flowID: UUID, next: AnalyticsAuthDestination)
    case authAttemptStarted(flowID: UUID, attemptID: UUID, method: AnalyticsAuthMethod)
    case authAttemptFinished(flowID: UUID, attemptID: UUID, method: AnalyticsAuthMethod, outcome: AnalyticsAuthOutcome)
    case login(flowID: UUID, attemptID: UUID, method: AnalyticsAuthMethod)
    case signUp(flowID: UUID, method: AnalyticsAuthMethod)
    case profileSetupFinished(flowID: UUID, outcome: AnalyticsProfileOutcome)
    case guestStarted(flowID: UUID)
    case contentSelected(AnalyticsSelectedContent, list: AnalyticsListContext)
    case contentStateViewed(surface: AnalyticsSurface, state: AnalyticsContentState, list: AnalyticsListContext?, date: AnalyticsDateRelation?)
    case searchStarted(list: AnalyticsListContext, source: AnalyticsQuerySource)
    case searchFinished(list: AnalyticsListContext, source: AnalyticsQuerySource, hasResults: Bool)
    case articleOpened(AnalyticsArticleContext)
    case articleRendered(AnalyticsArticleContext, newsletter: AnalyticsNewsletter)
    case articleEngaged(AnalyticsArticleContext, newsletter: AnalyticsNewsletter, activeVisibleMilliseconds: Int)
    case newsletterDetailViewed(AnalyticsNewsletter, viewID: UUID, source: AnalyticsContentSource, status: AnalyticsSubscriptionStatus)
    case subscribeStarted(AnalyticsNewsletter, attemptID: UUID, viewID: UUID?, status: AnalyticsSubscriptionStatus)
    case subscribePageOpened(AnalyticsNewsletter, attemptID: UUID)
    case subscribePageClosed(AnalyticsNewsletter, attemptID: UUID)
    case homeActionSelected(state: AnalyticsContentState, action: AnalyticsHomeAction, date: AnalyticsDateRelation)
    case operationFailed(AnalyticsOperation, category: AnalyticsFailureCategory)
    case bookmarkChanged(AnalyticsArticleContext, newsletter: AnalyticsNewsletter, action: AnalyticsBookmarkAction)
    case highlightApplied(AnalyticsArticleContext, newsletter: AnalyticsNewsletter)
}

public enum AnalyticsEnvironment: String, Sendable { case production, development }
public enum AnalyticsAuthState: String, Sendable { case unauthenticated, guest, authenticated, unknown }

public struct AnalyticsCommonProperties: Sendable {
    public let environment: AnalyticsEnvironment
    public let build: String
    public let authState: AnalyticsAuthState

    public init(environment: AnalyticsEnvironment, build: String, authState: AnalyticsAuthState) {
        self.environment = environment
        self.build = build
        self.authState = authState
    }
}

public enum AnalyticsValue: Sendable, Equatable {
    case string(String)
    case integer(Int)
}

public struct AnalyticsPayload: Sendable, Equatable {
    public let name: String
    public let parameters: [String: AnalyticsValue]
}

public extension AnalyticsEvent {
    /// The contract exposes only approved scalar fields, never arbitrary user dictionaries.
    func payload(common: AnalyticsCommonProperties, from entryPoint: AnalyticsEntryPoint) -> AnalyticsPayload? {
        var builder = PayloadBuilder()
        builder.values = [
            "event_version": .integer(1), "measurement_env": .string(common.environment.rawValue),
            "app_build": .string(common.build), "auth_state": .string(common.authState.rawValue),
            "entry_point": .string(entryPoint.rawValue)
        ]
        let name: String
        switch self {
        case let .screenViewed(screen, step, flowID):
            name = "screen_view"
            builder.text("screen_name", screen.rawValue)
            if let step {
                guard (screen == .onboarding && step.isOnboarding) || (screen == .signup && !step.isOnboarding) else { return nil }
                builder.text("step_key", step.rawValue)
            } else if screen == .onboarding || screen == .signup { return nil }
            builder.uuid("auth_flow_id", flowID)
        case let .onboardingCompleted(flowID, next):
            name = "onboarding_completed"
            builder.uuid("auth_flow_id", flowID)
            builder.text("next_screen", next.rawValue)
        case let .authAttemptStarted(flowID, attemptID, method):
            name = "auth_attempt_started"
            builder.auth(flowID, attemptID, method)
        case let .authAttemptFinished(flowID, attemptID, method, outcome):
            name = "auth_attempt_finished"
            builder.auth(flowID, attemptID, method)
            switch outcome {
            case .signupRequired: builder.text("outcome", "signup_required")
            case .cancelled: builder.text("outcome", "cancelled")
            case .failed(let category):
                builder.text("outcome", "failed")
                builder.text("error_category", category.rawValue)
            }
        case let .login(flowID, attemptID, method):
            name = "login"
            builder.auth(flowID, attemptID, method)
        case let .signUp(flowID, method):
            name = "sign_up"
            builder.uuid("auth_flow_id", flowID)
            builder.text("method", method.rawValue)
        case let .profileSetupFinished(flowID, outcome):
            name = "profile_setup_finished"
            builder.uuid("auth_flow_id", flowID)
            builder.text("outcome", outcome.rawValue)
        case let .guestStarted(flowID):
            name = "guest_started"
            builder.uuid("auth_flow_id", flowID)
        case let .contentSelected(content, list):
            name = "select_content"
            builder.list(list)
            switch content {
            case .article(let id):
                builder.text("content_type", "article")
                builder.identifier("item_id", id)
            case .newsletter(let newsletter):
                builder.text("content_type", "newsletter")
                builder.identifier("item_id", newsletter.id)
                builder.newsletter(newsletter)
            }
        case let .contentStateViewed(surface, state, list, date):
            name = "content_state_viewed"
            guard state != .noArticlesOnDate || surface == .home else { return nil }
            guard surface != .home || date != nil else { return nil }
            guard state == .guest || list != nil else { return nil }
            builder.text("surface", surface.rawValue)
            builder.text("state", state.state)
            builder.text("reason", state.reason)
            if let list { builder.list(list) }
            if let date { builder.text("date_relation", date.rawValue) }
        case let .searchStarted(list, source):
            name = "newsletter_search_started"
            guard list.list == .searchNewsletters else { return nil }
            builder.uuid("list_view_id", list.id)
            builder.text("query_source", source.rawValue)
        case let .searchFinished(list, source, hasResults):
            name = "newsletter_search_finished"
            guard list.list == .searchNewsletters else { return nil }
            builder.uuid("list_view_id", list.id)
            builder.text("query_source", source.rawValue)
            builder.text("result_bucket", hasResults ? "non_zero" : "zero")
        case let .articleOpened(article):
            name = "article_opened"
            builder.article(article)
        case let .articleRendered(article, newsletter):
            name = "article_rendered"
            builder.article(article)
            builder.newsletter(newsletter)
        case let .articleEngaged(article, newsletter, milliseconds):
            name = "article_engaged"
            guard milliseconds >= 30_000 else { return nil }
            builder.article(article)
            builder.newsletter(newsletter)
            builder.text("engagement_rule", "visible_30s_v1")
            builder.values["active_visible_ms"] = .integer(milliseconds)
        case let .newsletterDetailViewed(newsletter, viewID, source, status):
            name = "newsletter_detail_viewed"
            builder.newsletter(newsletter)
            builder.uuid("newsletter_view_id", viewID)
            builder.uuid("list_view_id", source.list?.id)
            builder.text("subscription_status", status.rawValue)
        case let .subscribeStarted(newsletter, attemptID, viewID, status):
            name = "newsletter_subscribe_started"
            guard entryPoint == .newsletterDetail || entryPoint == .signupCuration else { return nil }
            guard entryPoint != .newsletterDetail || viewID != nil else { return nil }
            builder.newsletter(newsletter)
            builder.uuid("subscription_attempt_id", attemptID)
            builder.uuid("newsletter_view_id", viewID)
            builder.text("subscription_status", status.rawValue)
        case let .subscribePageOpened(newsletter, attemptID):
            name = "newsletter_subscribe_page_opened"
            builder.newsletter(newsletter)
            builder.uuid("subscription_attempt_id", attemptID)
        case let .subscribePageClosed(newsletter, attemptID):
            name = "newsletter_subscribe_page_closed"
            builder.newsletter(newsletter)
            builder.uuid("subscription_attempt_id", attemptID)
        case let .homeActionSelected(state, action, date):
            name = "home_action_selected"
            builder.text("state", state.state)
            builder.text("reason", state.reason)
            builder.text("action", action.rawValue)
            builder.text("date_relation", date.rawValue)
        case let .operationFailed(operation, category):
            name = "operation_failed"
            builder.operation(operation)
            builder.text("error_category", category.rawValue)
        case let .bookmarkChanged(article, newsletter, action):
            name = "bookmark_changed"
            builder.savedArticle(article, newsletter)
            builder.text("action", action.rawValue)
        case let .highlightApplied(article, newsletter):
            name = "highlight_applied"
            builder.savedArticle(article, newsletter)
        }
        guard builder.valid, builder.values.count <= 25,
              builder.values.values.allSatisfy({ value in
                  switch value {
                  case .integer: true
                  case .string(let text): !text.isEmpty && text.utf16.count <= 100
                  }
              }) else { return nil }
        return AnalyticsPayload(name: name, parameters: builder.values)
    }
}

private struct PayloadBuilder {
    var values: [String: AnalyticsValue] = [:]
    var valid = true

    mutating func text(_ key: String, _ value: String) { values[key] = .string(value) }

    mutating func identifier(_ key: String, _ value: String) {
        guard !value.isEmpty, value.utf16.count <= 100,
              value.unicodeScalars.allSatisfy({ CharacterSet.alphanumerics.contains($0) || $0 == "-" || $0 == "_" }),
              Int(value).map({ $0 > 0 }) ?? true else { valid = false; return }
        text(key, value)
    }

    mutating func uuid(_ key: String, _ value: UUID?) {
        if let value { text(key, value.uuidString.lowercased()) }
    }

    mutating func newsletter(_ newsletter: AnalyticsNewsletter) {
        identifier("newsletter_id", newsletter.id)
        if let name = newsletter.name?.trimmingCharacters(in: .whitespacesAndNewlines),
           !name.isEmpty, name.utf16.count <= 100 {
            text("newsletter_name", name)
        }
    }

    mutating func list(_ list: AnalyticsListContext) {
        text("list_id", list.list.rawValue)
        uuid("list_view_id", list.id)
    }

    mutating func auth(_ flow: UUID, _ attempt: UUID, _ method: AnalyticsAuthMethod) {
        uuid("auth_flow_id", flow)
        uuid("auth_attempt_id", attempt)
        text("method", method.rawValue)
    }

    mutating func article(_ article: AnalyticsArticleContext) {
        identifier("item_id", article.id)
        uuid("article_view_id", article.viewID)
        text("article_kind", article.kind.rawValue)
        uuid("list_view_id", article.source.list?.id)
    }

    mutating func savedArticle(_ article: AnalyticsArticleContext, _ newsletter: AnalyticsNewsletter) {
        identifier("item_id", article.id)
        uuid("article_view_id", article.viewID)
        self.newsletter(newsletter)
    }

    mutating func operation(_ operation: AnalyticsOperation) {
        switch operation {
        case .signup(let flowID):
            text("operation", "signup_submit"); uuid("auth_flow_id", flowID)
        case .profile(let flowID):
            text("operation", "profile_setup"); uuid("auth_flow_id", flowID)
        case .list(let context):
            text("operation", context.list == .homeArticles ? "home_load" : context.list == .searchNewsletters ? "newsletter_search" : "content_load")
            list(context)
        case let .newsletter(id, viewID):
            text("operation", "newsletter_detail_load")
            identifier("newsletter_id", id); uuid("newsletter_view_id", viewID)
        case .articleLoad(let context):
            text("operation", "article_load")
            savedArticleLoad(context)
        case let .articleRender(context, newsletter):
            text("operation", "article_render")
            savedArticleLoad(context); identifier("newsletter_id", newsletter.id)
        case let .subscribePage(newsletter, attemptID):
            text("operation", "subscribe_page_load")
            identifier("newsletter_id", newsletter.id); uuid("subscription_attempt_id", attemptID)
        case let .bookmark(context, newsletter):
            text("operation", "bookmark_update")
            identifier("item_id", context.id); uuid("article_view_id", context.viewID); identifier("newsletter_id", newsletter.id)
        case let .highlight(context, newsletter):
            text("operation", "highlight_save")
            identifier("item_id", context.id); uuid("article_view_id", context.viewID); identifier("newsletter_id", newsletter.id)
        }
    }

    private mutating func savedArticleLoad(_ context: AnalyticsArticleContext) {
        identifier("item_id", context.id)
        uuid("article_view_id", context.viewID)
        text("article_kind", context.kind.rawValue)
    }
}
