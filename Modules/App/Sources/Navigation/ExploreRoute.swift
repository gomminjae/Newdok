enum ExploreRoute: Hashable {
    case search
    case brandDetail(id: String)
    case articleDetail(id: String, isPast: Bool)
    case feedback
}
