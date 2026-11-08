import Shared

enum HomeRoute: Hashable {
    case search
    case articleDetail(id: String, isPast: Bool, source: AnalyticsContentSource)
    case brandDetail(id: String, source: AnalyticsContentSource)
    case feedback
}

extension HomeRoute {
    var analyticsEntryPoint: AnalyticsEntryPoint {
        switch self {
        case .search: .search
        case .articleDetail: .articleDetail
        case .brandDetail: .newsletterDetail
        case .feedback: .unknown
        }
    }
}
