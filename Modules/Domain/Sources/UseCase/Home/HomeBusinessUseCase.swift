//
//  HomeBusinessUseCase.swift
//  Domain
//
//  Created by 권민재 on 4/22/25.
//

import Foundation
import Shared

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
}

public actor DefaultHomeBusinessUseCase: HomeBusinessUseCase {
    private enum Constants {
        static let readArticlesKey = "readArticles"
    }
    
    private let fetchUseCase: FetchHomeDataUseCase
    
    private var snapshotState: HomeSnapshot
    private var monthlyCache: [String: [Articles]] = [:]
    private var dataDaysByMonthCache: [String: Set<Int>] = [:]
    private var readArticleIds: Set<Int> = []
    private var lastLoadedDate: Date?
    private var cachedTodayArticles: [Article]?
    private var cachedTodayDate: Date?
    private var isTodayLoading = false
    private var warmupTask: Task<Void, Never>?
    
    public init(fetchUseCase: FetchHomeDataUseCase) {
        self.fetchUseCase = fetchUseCase
        let today = Date()
        let month = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: today)
        ) ?? today
        snapshotState = HomeSnapshot(
            selectedDate: today,
            displayedMonth: month,
            filteredArticles: [],
            subscribedNewsletters: [],
            articlesByMonth: [],
            dataDays: [],
            isLoaded: false,
            isCalendarLoading: false
        )
        loadReadArticleIds()
    }
    
    public func snapshot() async -> HomeSnapshot {
        snapshotState
    }
    
    public func loadToday() async -> HomeSnapshot {
        if isTodayLoading { return snapshotState }
        isTodayLoading = true
        defer { isTodayLoading = false }
        
        do {
            let data = try await fetchUseCase.fetchTodayData()
            let today = strippedDate(Date())
            let month = startOfMonth(today)
            let processedArticles = fetchUseCase.decorateTodayArticles(
                data.articles,
                readArticleIds: readArticleIds
            )
            
            cachedTodayArticles = processedArticles
            cachedTodayDate = today
            
            snapshotState.selectedDate = today
            snapshotState.displayedMonth = month
            snapshotState.subscribedNewsletters = data.activeNewsletters
            
            clearMonthlyCache(for: today)
            _ = await loadMonthData(for: today, forceReload: true)
            updateTodayArticlesCache(with: processedArticles, for: today)
            
            snapshotState.filteredArticles = filterArticles(for: today)
            snapshotState.isLoaded = true
            lastLoadedDate = today
            startWarmup(for: today)
        } catch {
            snapshotState.isLoaded = true
            snapshotState.isCalendarLoading = false
        }
        return snapshotState
    }
    
    public func refreshToToday() async -> HomeSnapshot {
        await loadToday()
    }
    
    public func loadMonthData(for date: Date, forceReload: Bool = false) async -> HomeSnapshot {
        let key = monthKey(for: date)
        let month = startOfMonth(date)
        
        if !forceReload, let cached = monthlyCache[key] {
            snapshotState.displayedMonth = month
            snapshotState.articlesByMonth = cached
            snapshotState.dataDays = dataDaysByMonthCache[key] ?? []
            snapshotState.filteredArticles = filterArticles()
            snapshotState.isCalendarLoading = false
            return snapshotState
        }
        
        if let cachedDays = dataDaysByMonthCache[key] {
            snapshotState.dataDays = cachedDays
        }
        
        snapshotState.isCalendarLoading = true
        do {
            let monthly = try await fetchMonthly(for: date)
            snapshotState.displayedMonth = month
            snapshotState.articlesByMonth = monthly
            snapshotState.filteredArticles = filterArticles()
            updateDataDays(with: monthly, forKey: key)
            snapshotState.isCalendarLoading = false
            monthlyCache[key] = monthly
        } catch {
            if Task.isCancelled { return snapshotState }
            snapshotState.isCalendarLoading = false
        }
        
        maybeWarmup(for: date)
        return snapshotState
    }
    
    public func loadMonthDataIfNeeded(for date: Date) async -> HomeSnapshot {
        let key = monthKey(for: date)
        if monthlyCache[key] != nil {
            return await loadMonthData(for: date, forceReload: false)
        }
        return await loadMonthData(for: date, forceReload: true)
    }
    
    public func selectDateWithMonthGuarantee(_ date: Date) async -> HomeSnapshot {
        snapshotState.selectedDate = date
        if Calendar.current.isDate(date, equalTo: snapshotState.displayedMonth, toGranularity: .month) {
            snapshotState.filteredArticles = filterArticles(for: date)
            return snapshotState
        }
        
        await loadMonthData(for: date)
        snapshotState.filteredArticles = filterArticles(for: date)
        return snapshotState
    }
    
    public func refreshCurrentData() async -> HomeSnapshot {
        snapshotState.filteredArticles = filterArticles()
        return snapshotState
    }
    
    public func markArticleAsRead(articleId: Int) async -> HomeSnapshot {
        readArticleIds.insert(articleId)
        saveReadArticleIds()
        
        snapshotState.articlesByMonth = fetchUseCase.decorateMonthlyArticles(
            snapshotState.articlesByMonth,
            readArticleIds: readArticleIds
        )
        
        updateCachesAfterRead()
        snapshotState.filteredArticles = filterArticles()
        return snapshotState
    }
    
    public func resetForAuthChange() async -> HomeSnapshot {
        warmupTask?.cancel()
        warmupTask = nil
        monthlyCache.removeAll()
        dataDaysByMonthCache.removeAll()
        lastLoadedDate = nil
        cachedTodayArticles = nil
        cachedTodayDate = nil
        isTodayLoading = false
        
        let today = Date()
        snapshotState = HomeSnapshot(
            selectedDate: today,
            displayedMonth: startOfMonth(today),
            filteredArticles: [],
            subscribedNewsletters: [],
            articlesByMonth: [],
            dataDays: [],
            isLoaded: false,
            isCalendarLoading: false
        )
        return snapshotState
    }
    
    public func shouldReloadToday(currentDate: Date = Date()) async -> Bool {
        if !snapshotState.isLoaded { return true }
        guard let lastLoadedDate else { return true }
        return !Calendar.current.isDate(lastLoadedDate, inSameDayAs: currentDate)
    }
    
    public func cachedDataDays(for date: Date) async -> Set<Int> {
        dataDaysByMonthCache[monthKey(for: date)] ?? []
    }
    
    // MARK: - Helpers
    private func fetchMonthly(for date: Date) async throws -> [Articles] {
        let monthly = try await fetchUseCase.fetchMonthlyData(
            year: formatYear(date),
            month: formatMonth(date)
        )
        let decorated = fetchUseCase.decorateMonthlyArticles(monthly, readArticleIds: readArticleIds)
        return mergeTodayCache(into: decorated, for: date)
    }
    
    private func updateDataDays(with monthly: [Articles], forKey key: String, affectsSnapshot: Bool = true) {
        let days = Set(
            monthly
                .filter { !$0.receivedArticleList.isEmpty }
                .map { $0.publishDate }
        )
        if affectsSnapshot, key == monthKey(for: snapshotState.displayedMonth) {
            snapshotState.dataDays = days
        }
        dataDaysByMonthCache[key] = days
    }
    
    private func filterArticles(for date: Date? = nil) -> [Article] {
        let target = date ?? snapshotState.selectedDate
        let day = Calendar.current.component(.day, from: target)
        return snapshotState.articlesByMonth
            .first(where: { $0.publishDate == day })?
            .receivedArticleList ?? []
    }
    
    private func formatYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: date)
    }
    
    private func strippedDate(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }
    
    private func startOfMonth(_ date: Date) -> Date {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }
    
    private func monthKey(for date: Date) -> String {
        "\(formatYear(date))-\(formatMonth(date))"
    }
    
    private func mergeTodayCache(into monthly: [Articles], for date: Date) -> [Articles] {
        guard
            let cachedDate = cachedTodayDate,
            let cachedArticles = cachedTodayArticles,
            Calendar.current.isDate(cachedDate, equalTo: date, toGranularity: .month)
        else {
            return monthly
        }
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: cachedDate)
        let unread = fetchUseCase.unreadCount(in: cachedArticles)
        let todayEntry = Articles(
            publishDate: day,
            receivedUnread: unread,
            receivedArticleList: cachedArticles
        )
        
        var merged = monthly
        if let index = merged.firstIndex(where: { $0.publishDate == day }) {
            merged[index] = todayEntry
        } else {
            merged.append(todayEntry)
            merged.sort { $0.publishDate < $1.publishDate }
        }
        return merged
    }
    
    private func updateTodayArticlesCache(with articles: [Article], for date: Date) {
        guard !articles.isEmpty else { return }
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let unread = fetchUseCase.unreadCount(in: articles)
        let todayEntry = Articles(
            publishDate: day,
            receivedUnread: unread,
            receivedArticleList: articles
        )
        
        if Calendar.current.isDate(date, equalTo: snapshotState.displayedMonth, toGranularity: .month) {
            if let index = snapshotState.articlesByMonth.firstIndex(where: { $0.publishDate == day }) {
                snapshotState.articlesByMonth[index] = todayEntry
            } else {
                snapshotState.articlesByMonth.append(todayEntry)
                snapshotState.articlesByMonth.sort { $0.publishDate < $1.publishDate }
            }
            snapshotState.filteredArticles = filterArticles()
        }
        
        let key = monthKey(for: date)
        var cache = monthlyCache[key] ?? []
        if let index = cache.firstIndex(where: { $0.publishDate == day }) {
            cache[index] = todayEntry
        } else {
            cache.append(todayEntry)
            cache.sort { $0.publishDate < $1.publishDate }
        }
        monthlyCache[key] = cache
        updateDataDays(with: cache, forKey: key)
    }
    
    private func clearMonthlyCache(for date: Date) {
        let key = monthKey(for: date)
        monthlyCache.removeValue(forKey: key)
        dataDaysByMonthCache.removeValue(forKey: key)
    }
    
    private func loadReadArticleIds() {
        if
            let data = UserDefaults.standard.data(forKey: Constants.readArticlesKey),
            let ids = try? JSONDecoder().decode(Set<Int>.self, from: data)
        {
            readArticleIds = ids
        }
    }
    
    private func saveReadArticleIds() {
        if let data = try? JSONEncoder().encode(readArticleIds) {
            UserDefaults.standard.set(data, forKey: Constants.readArticlesKey)
        }
    }
    
    private func updateCachesAfterRead() {
        let key = monthKey(for: snapshotState.displayedMonth)
        monthlyCache[key] = snapshotState.articlesByMonth
        updateDataDays(with: snapshotState.articlesByMonth, forKey: key)
        
        if let cachedDate = lastLoadedDate,
           Calendar.current.isDate(cachedDate, equalTo: snapshotState.displayedMonth, toGranularity: .month)
        {
            let day = Calendar.current.component(.day, from: cachedDate)
            if let todayEntry = snapshotState.articlesByMonth.first(where: { $0.publishDate == day }) {
                cachedTodayArticles = todayEntry.receivedArticleList
                cachedTodayDate = cachedDate
            }
        }
    }
    
    private func startWarmup(for date: Date) {
        warmupTask?.cancel()
        warmupTask = Task.detached { [weak self] in
            guard let self else { return }
            await self.warmupCurrentYear(for: date)
        }
    }
    
    private func maybeWarmup(for date: Date) {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let targetYear = calendar.component(.year, from: date)
        if currentYear == targetYear {
            startWarmup(for: date)
        }
    }
    
    private func warmupCurrentYear(for date: Date) async {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: date)
        let currentMonth = calendar.component(.month, from: date)
        
        for month in 1...currentMonth {
            if Task.isCancelled { return }
            var components = DateComponents()
            components.year = currentYear
            components.month = month
            components.day = 1
            if let monthDate = calendar.date(from: components) {
                await loadMonthDataSilently(for: monthDate)
            }
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }
    
    private func loadMonthDataSilently(for date: Date) async {
        let key = monthKey(for: date)
        if monthlyCache[key] != nil { return }
        
        do {
            let monthly = try await fetchMonthly(for: date)
            monthlyCache[key] = monthly
            updateDataDays(with: monthly, forKey: key, affectsSnapshot: false)
        } catch {
            // Intentionally ignore background failures.
        }
    }
}
