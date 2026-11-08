import Foundation

public enum AnalyticsEntryPoint: String, Sendable, Hashable {
    case launch, onboarding, login, signup, home, search, subscriptions, bookmarks, mypage
    case signupCuration = "signup_curation"
    case exploreRecommended = "explore_recommended"
    case exploreAll = "explore_all"
    case newsletterDetail = "newsletter_detail"
    case articleDetail = "article_detail"
    case deepLink = "deep_link"
    case unknown
}

public enum AnalyticsScreen: String, Sendable, Hashable {
    case onboarding, login, signup, home, explore, search, subscriptions, bookmarks, mypage
    case newsletterDetail = "newsletter_detail"
    case articleDetail = "article_detail"
    case subscribeWeb = "subscribe_web"
}

public enum AnalyticsStep: String, Sendable, Hashable {
    case intro1 = "intro_1", intro2 = "intro_2", intro3 = "intro_3"
    case profile, terms, industry, interests, curation
    case accountComplete = "account_complete"
    case recommendIntro = "recommend_intro"

    public var isOnboarding: Bool {
        switch self {
        case .intro1, .intro2, .intro3: true
        default: false
        }
    }
}

public enum AnalyticsAuthMethod: String, Sendable { case apple, kakao }
public enum AnalyticsAuthDestination: String, Sendable { case login, signup }
public enum AnalyticsProfileOutcome: String, Sendable { case completed, skipped }
public enum AnalyticsQuerySource: String, Sendable { case typed, popularKeyword = "popular_keyword" }
public enum AnalyticsArticleKind: String, Sendable, Hashable { case current, past }
public enum AnalyticsBookmarkAction: String, Sendable { case added, removed }
public enum AnalyticsSubscriptionStatus: String, Sendable {
    case initial, check, confirmed, paused, unknown
}
public enum AnalyticsHomeAction: String, Sendable {
    case signup, login, retry
    case exploreRecommended = "explore_recommended"
    case exploreByDay = "explore_by_day"
    case changeDate = "change_date"
}

public enum AnalyticsDateRelation: String, Sendable, Hashable {
    case today, past, future

    public init(date: Date, today: Date = Date(), calendar: Calendar = .current) {
        if calendar.isDate(date, inSameDayAs: today) { self = .today }
        else { self = date < today ? .past : .future }
    }
}

public enum AnalyticsSurface: String, Sendable, Hashable {
    case home, explore, search, subscriptions, bookmarks
    case signupCuration = "signup_curation"
    case newsletterArticles = "newsletter_articles"
}

public enum AnalyticsListID: String, Sendable, Hashable {
    case homeArticles = "home_articles"
    case newsletterArticles = "newsletter_articles"
    case exploreRecommended = "explore_recommended"
    case exploreAll = "explore_all"
    case searchNewsletters = "search_newsletters"
    case subscribedNewsletters = "subscribed_newsletters"
    case pausedNewsletters = "paused_newsletters"
    case bookmarkedArticles = "bookmarked_articles"
    case signupCuration = "signup_curation"

    public var entryPoint: AnalyticsEntryPoint {
        switch self {
        case .homeArticles: .home
        case .newsletterArticles: .newsletterDetail
        case .exploreRecommended: .exploreRecommended
        case .exploreAll: .exploreAll
        case .searchNewsletters: .search
        case .subscribedNewsletters, .pausedNewsletters: .subscriptions
        case .bookmarkedArticles: .bookmarks
        case .signupCuration: .signupCuration
        }
    }

    public var surface: AnalyticsSurface {
        switch self {
        case .homeArticles: .home
        case .newsletterArticles: .newsletterArticles
        case .exploreRecommended, .exploreAll: .explore
        case .searchNewsletters: .search
        case .subscribedNewsletters, .pausedNewsletters: .subscriptions
        case .bookmarkedArticles: .bookmarks
        case .signupCuration: .signupCuration
        }
    }
}

public struct AnalyticsListContext: Sendable, Hashable {
    public let list: AnalyticsListID
    public let id: UUID

    public init(_ list: AnalyticsListID, id: UUID = UUID()) {
        self.list = list
        self.id = id
    }
}

public struct AnalyticsContentSource: Sendable, Hashable {
    public let entryPoint: AnalyticsEntryPoint
    public let list: AnalyticsListContext?

    public init(entryPoint: AnalyticsEntryPoint, list: AnalyticsListContext? = nil) {
        self.entryPoint = entryPoint
        self.list = list
    }

    public init(list: AnalyticsListContext) {
        self.init(entryPoint: list.list.entryPoint, list: list)
    }

    public static let unknown = Self(entryPoint: .unknown)
}

public struct AnalyticsNewsletter: Sendable, Equatable {
    public let id: String
    public let name: String?

    public init(id: String, name: String? = nil) {
        self.id = id
        self.name = name
    }
}

public enum AnalyticsSelectedContent: Sendable {
    case article(id: String)
    case newsletter(AnalyticsNewsletter)
}

public struct AnalyticsArticleContext: Sendable, Hashable {
    public let id: String
    public let viewID: UUID
    public let kind: AnalyticsArticleKind
    public let source: AnalyticsContentSource

    public init(id: String, kind: AnalyticsArticleKind, source: AnalyticsContentSource = .unknown, viewID: UUID = UUID()) {
        self.id = id
        self.kind = kind
        self.source = source
        self.viewID = viewID
    }
}

public enum AnalyticsContentState: Sendable, Hashable {
    case ready, guest, noSubscriptions, noArticlesOnDate, noResults, failed

    public var state: String {
        switch self {
        case .ready: "ready"
        case .guest: "guest"
        case .noSubscriptions, .noArticlesOnDate, .noResults: "empty"
        case .failed: "failed"
        }
    }

    public var reason: String {
        switch self {
        case .ready: "none"
        case .guest: "authentication_required"
        case .noSubscriptions: "no_subscriptions"
        case .noArticlesOnDate: "no_articles_on_date"
        case .noResults: "no_results"
        case .failed: "request_failed"
        }
    }
}

public enum AnalyticsFailureCategory: String, Sendable {
    case network, server, authentication, validation, sdk, rendering, unknown

    public init(error: Error) {
        let mapped = (error as? AppErrorConvertible)?.toAppError()
            ?? (error as? AppError)
            ?? AppErrorMapperRegistry.map(error)
        switch mapped {
        case .noInternet, .timeout: self = .network
        case .serverError, .serverMessage: self = .server
        case .unauthorized: self = .authentication
        default: self = error is URLError ? .network : .unknown
        }
    }
}

public enum AnalyticsAuthOutcome: Sendable {
    case signupRequired, cancelled, failed(AnalyticsFailureCategory)
}

@MainActor
public final class AuthAnalyticsContext {
    public let flowID: UUID
    public let entryPoint: AnalyticsEntryPoint
    public private(set) var method: AnalyticsAuthMethod?
    public private(set) var attemptID: UUID?

    public init(flowID: UUID = UUID(), entryPoint: AnalyticsEntryPoint = .unknown) {
        self.flowID = flowID
        self.entryPoint = entryPoint
    }

    public func beginAttempt(method: AnalyticsAuthMethod) -> UUID {
        let id = UUID()
        self.method = method
        attemptID = id
        return id
    }

    public func isCurrent(_ id: UUID) -> Bool { attemptID == id }
    public func finishAttempt(_ id: UUID) { if attemptID == id { attemptID = nil } }
    public func invalidate() { attemptID = nil }
}
