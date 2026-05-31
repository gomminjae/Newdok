public enum ExploreOrderOption: String, Sendable, CaseIterable {
    case popular = "인기순"
    case newest = "최신순"

    public var displayText: String {
        switch self {
        case .popular: return "인기순"
        case .newest: return "최신등록순"
        }
    }
}
