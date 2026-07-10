enum HomeRoute: Hashable {
    case search
    case articleDetail(id: String, isPast: Bool)
    case brandDetail(id: String)
    case feedback
}
