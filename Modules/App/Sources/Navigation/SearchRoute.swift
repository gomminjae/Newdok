import Shared

enum SearchRoute: Hashable {
    case brandDetail(id: String, source: AnalyticsContentSource)
    case articleDetail(id: String, isPast: Bool, source: AnalyticsContentSource)
    case feedback

    var analyticsEntryPoint: AnalyticsEntryPoint {
        switch self {
        case .brandDetail: .newsletterDetail
        case .articleDetail: .articleDetail
        case .feedback: .unknown
        }
    }
}
