import Shared

enum SubscribeRoute: Hashable {
    case search
    case brandDetail(id: String, source: AnalyticsContentSource)
    case articleDetail(id: String, isPast: Bool, source: AnalyticsContentSource)
    case feedback
}

extension SubscribeRoute {
    var analyticsEntryPoint: AnalyticsEntryPoint {
        switch self {
        case .search: .search
        case .articleDetail: .articleDetail
        case .brandDetail: .newsletterDetail
        case .feedback: .unknown
        }
    }
}
