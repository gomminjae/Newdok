import Shared

enum BookmarkRoute: Hashable {
    case search
    case articleDetail(id: String, isPast: Bool, source: AnalyticsContentSource)
    case brandDetail(id: String, source: AnalyticsContentSource)
    case feedback
}

extension BookmarkRoute {
    var analyticsEntryPoint: AnalyticsEntryPoint {
        switch self {
        case .search: .search
        case .articleDetail: .articleDetail
        case .brandDetail: .newsletterDetail
        case .feedback: .unknown
        }
    }
}
