//
//  HomeBusinessUseCase.swift
//  Domain
//
//  Created by 권민재 on 4/22/25.
//

import Foundation

public struct HomeSnapshot: @unchecked Sendable {
    public var selectedDate: Date
    public var displayedMonth: Date
    public var filteredArticles: [Article]
    public var subscribedNewsletters: [Newsletter]
    public var articlesByMonth: [Articles]
    public var dataDays: Set<Int>
    public var isLoaded: Bool
    public var isCalendarLoading: Bool
    
    public init(
        selectedDate: Date,
        displayedMonth: Date,
        filteredArticles: [Article],
        subscribedNewsletters: [Newsletter],
        articlesByMonth: [Articles],
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

public protocol HomeBusinessUseCase: AnyObject {
    func snapshot() async -> HomeSnapshot
    func loadToday() async -> HomeSnapshot
    func loadMonthData(for date: Date, forceReload: Bool) async -> HomeSnapshot
    func loadMonthDataIfNeeded(for date: Date) async -> HomeSnapshot
    func selectDateWithMonthGuarantee(_ date: Date) async -> HomeSnapshot
    func refreshCurrentData() async -> HomeSnapshot
    func refreshToToday() async -> HomeSnapshot
    func markArticleAsRead(articleId: Int) async -> HomeSnapshot
    func resetForAuthChange() async -> HomeSnapshot
    func shouldReloadToday(currentDate: Date) async -> Bool
    func cachedDataDays(for date: Date) async -> Set<Int>
    func fetchDataDays(for date: Date) async -> Set<Int>
}
