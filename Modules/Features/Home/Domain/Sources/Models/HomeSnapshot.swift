import Foundation

public struct HomeSnapshot: Sendable {
    public var selectedDate: Date
    public var displayedMonth: Date
    public var filteredArticles: [HomeArticle]
    public var subscribedNewsletters: [HomeNewsletter]
    public var articlesByMonth: [HomeArticles]
    public var dataDays: Set<Int>
    public var isLoaded: Bool
    public var isCalendarLoading: Bool

    public init(
        selectedDate: Date,
        displayedMonth: Date,
        filteredArticles: [HomeArticle],
        subscribedNewsletters: [HomeNewsletter],
        articlesByMonth: [HomeArticles],
        dataDays: Set<Int>,
        isLoaded: Bool,
        isCalendarLoading: Bool
    ) {
        self.selectedDate = selectedDate
        self.displayedMonth = displayedMonth
        self.filteredArticles = filteredArticles
        self.subscribedNewsletters = subscribedNewsletters
        self.articlesByMonth = articlesByMonth
        self.dataDays = dataDays
        self.isLoaded = isLoaded
        self.isCalendarLoading = isCalendarLoading
    }
}
