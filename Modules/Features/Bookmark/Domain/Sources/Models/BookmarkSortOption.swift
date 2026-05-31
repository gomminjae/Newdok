public enum BookmarkSortOption: String, Sendable, CaseIterable {
    case bookmarkDate = "bookmark_date"
    case articleDateDesc = "article_date_desc"
    case articleDateAsc = "article_date_asc"

    public var displayText: String {
        switch self {
        case .bookmarkDate: return "추가순"
        case .articleDateDesc: return "최근 아티클 순"
        case .articleDateAsc: return "오래된 아티클 순"
        }
    }
}
