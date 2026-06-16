//
//  HomeViewModel.swift
//  Home
//
//  Created by 권민재 on 4/16/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import HomeDomain
import Shared
import FoundationKit
import Foundation
import Observation

// MARK: - Calendar State
public struct CalendarState {
    public var selectedDate: Date
    public var displayedMonth: Date
    public var dataDays: Set<Int> = []
    public var isLoading: Bool = false

    public init(initialDate: Date = Date()) {
        self.selectedDate = initialDate
        self.displayedMonth = initialDate
    }
}

public enum HomeState {
    case idle
    case loading
    case guest
    case noSubscriptions
    case noArticles
    case articles
}

@Observable
@MainActor
public final class HomeViewModel: ErrorHandling {
    public var currentError: AppError?
    // MARK: - Dependencies
    private let fetchTodayArticlesUseCase: FetchTodayArticlesUseCase
    private let fetchMonthArticlesUseCase: FetchMonthArticlesUseCase
    private let fetchDayArticlesUseCase: FetchDayArticlesUseCase
    private let fetchNewslettersUseCase: FetchHomeNewslettersUseCase
    private let decorateArticlesUseCase: DecorateArticlesUseCase
    private let refreshArticlesUseCase: RefreshHomeArticlesUseCase
    private let loadReadIdsUseCase: LoadReadArticleIdsUseCase
    private let saveReadIdsUseCase: SaveReadArticleIdsUseCase
    private let extractArticleDaysUseCase: ExtractArticleDaysUseCase
    private let mergeDayArticleSummaryUseCase: MergeDayArticleSummaryUseCase
    private let appState: AppState

    // MARK: - Published State
    private var isBatchUpdating = false
    public var calendarState: CalendarState {
        didSet {
            guard !isBatchUpdating else { return }
            let oldMonth = oldValue.displayedMonth
            let newMonth = calendarState.displayedMonth
            guard !Calendar.current.isDate(oldMonth, equalTo: newMonth, toGranularity: .month) else { return }
            applyDataDaysForMonth(newMonth)
            monthLoadTask?.cancel()
            monthLoadTask = Task { [weak self] in
                await self?.loadMonthData(for: newMonth)
            }
        }
    }
    private var monthLoadTask: Task<Void, Never>?

    public var homeState: HomeState = .idle
    public var filteredArticles: [HomeArticle] = []
    public var subscribedNewsletters: [HomeNewsletter] = []
    public var articlesByMonth: [HomeArticles] = []

    // MARK: - Caches
    private let maxCachedMonths = 4
    private var dataDaysCache: [String: Set<Int>] = [:]
    private var monthlyCache: [String: [HomeArticles]] = [:]
    private var dayArticlesCache: [String: [HomeArticle]] = [:]
    private var cachedMonthOrder: [String] = []
    private var inFlightPrefetch: Set<String> = []
    private var readArticleIds: Set<Int> = []
    private var lastLoadedDate: Date?
    private var isTodayLoading = false
    private var isLoaded = false
    private var latestMonthRequestKey: String?
    private var latestDateSelectionKey: String?

    private var isGuest: Bool { appState.authState == .guest }

    public init(
        fetchTodayArticles: FetchTodayArticlesUseCase,
        fetchMonthArticles: FetchMonthArticlesUseCase,
        fetchDayArticles: FetchDayArticlesUseCase,
        fetchNewsletters: FetchHomeNewslettersUseCase,
        decorateArticles: DecorateArticlesUseCase,
        refreshArticles: RefreshHomeArticlesUseCase,
        loadReadIds: LoadReadArticleIdsUseCase,
        saveReadIds: SaveReadArticleIdsUseCase,
        extractArticleDays: ExtractArticleDaysUseCase,
        mergeDayArticleSummary: MergeDayArticleSummaryUseCase,
        appState: AppState
    ) {
        self.fetchTodayArticlesUseCase = fetchTodayArticles
        self.fetchMonthArticlesUseCase = fetchMonthArticles
        self.fetchDayArticlesUseCase = fetchDayArticles
        self.fetchNewslettersUseCase = fetchNewsletters
        self.decorateArticlesUseCase = decorateArticles
        self.refreshArticlesUseCase = refreshArticles
        self.loadReadIdsUseCase = loadReadIds
        self.saveReadIdsUseCase = saveReadIds
        self.extractArticleDaysUseCase = extractArticleDays
        self.mergeDayArticleSummaryUseCase = mergeDayArticleSummary
        self.appState = appState
        self.calendarState = CalendarState()
        self.readArticleIds = loadReadIds.execute()
    }

    // MARK: - Computed Properties
    public var selectedDate: Date {
        get { calendarState.selectedDate }
        set { calendarState.selectedDate = newValue }
    }

    public var displayedMonth: Date {
        get { calendarState.displayedMonth }
        set { calendarState.displayedMonth = newValue }
    }

    private func resolveState() -> HomeState {
        if isGuest { return .guest }
        if subscribedNewsletters.isEmpty && filteredArticles.isEmpty { return .noSubscriptions }
        if filteredArticles.isEmpty { return .noArticles }
        return .articles
    }

    public var formattedDate: String {
        selectedDate.newdokHomeDisplayText
    }

    // MARK: - Intent Handlers

    public func loadToday() async {
        guard !isGuest else {
            homeState = .guest
            return
        }
        if isTodayLoading { return }
        isTodayLoading = true
        defer { isTodayLoading = false }

        latestDateSelectionKey = nil
        if homeState == .idle { homeState = .loading }

        do {
            async let articlesTask = fetchTodayArticlesUseCase.execute()
            async let newslettersTask = fetchNewslettersUseCase.execute()
            let articles = try await articlesTask
            let newsletters = try await newslettersTask

            let today = strippedDate(Date())
            let month = startOfMonth(today)
            let processedArticles = await decorateArticles(articles)

            subscribedNewsletters = newsletters
            storeArticles(processedArticles, for: today)
            clearMonthlyCache(for: today)

            batchUpdate {
                calendarState.selectedDate = today
                calendarState.displayedMonth = month
            }

            await loadMonthInternal(for: today, forceReload: true)
            await updateFilteredArticles(for: today)
            isLoaded = true
            lastLoadedDate = today
            homeState = resolveState()
        } catch {
            handleError(error, feature: "home", operation: "loadToday")
            isLoaded = true
            calendarState.isLoading = false
            homeState = resolveState()
        }
    }

    public func loadMonthDataIfNeeded(for date: Date) async {
        let forceReload = monthlyCache[monthKey(for: date)] == nil
        await performMonthRequest(for: date, forceReload: forceReload)
    }

    public func loadMonthData(for date: Date, forceReload: Bool = false) async {
        await performMonthRequest(for: date, forceReload: forceReload)
    }

    public func selectDateWithMonthGuarantee(_ date: Date) {
        calendarState.selectedDate = date
        let selectionKey = dayKey(for: date)
        latestDateSelectionKey = selectionKey
        guard !isGuest else {
            homeState = .guest
            return
        }
        Task { [weak self] in
            guard let self else { return }
            if !Calendar.current.isDate(date, equalTo: calendarState.displayedMonth, toGranularity: .month) {
                await loadMonthInternal(for: date)
            }
            await updateFilteredArticles(for: date)
            guard latestDateSelectionKey == selectionKey else { return }
            homeState = resolveState()
        }
    }

    public func refreshCurrentData() async {
        await updateFilteredArticles()
        homeState = resolveState()
    }

    public func refreshToToday() async {
        guard !isGuest else {
            homeState = .guest
            return
        }
        latestDateSelectionKey = nil
        do {
            try await refreshArticlesUseCase.execute()
        } catch {
            handleError(error, feature: "home", operation: "refresh")
        }
        await loadToday()
    }

    public func applyDataDaysForMonth(_ date: Date) {
        calendarState.dataDays = dataDaysCache[monthKey(for: date)] ?? []
        Task { [weak self] in await self?.refreshDataDays(for: date) }
        prefetchAdjacent(from: date)
    }

    private func refreshDataDays(for date: Date) async {
        let days = await calendarDataDays(for: date)
        guard monthKey(for: date) == monthKey(for: calendarState.displayedMonth) else { return }
        calendarState.dataDays = days
    }

    public func markArticleAsRead(articleId: Int) async {
        readArticleIds.insert(articleId)
        saveReadIdsUseCase.execute(readArticleIds)

        let targetDate = calendarState.selectedDate
        if var cached = cachedArticles(for: targetDate) {
            cached = await decorateArticles(cached, refreshHighlightCounts: false)
            storeArticles(cached, for: targetDate)
            withAnimation(.easeInOut(duration: 0.25)) {
                filteredArticles = cached
            }
            applyMonthlyAdjustment(for: targetDate, articles: cached)
        } else {
            await updateFilteredArticles(for: targetDate)
        }
        homeState = resolveState()
    }

    public func resetForAuthChange() async {
        homeState = .loading
        dataDaysCache.removeAll()
        monthlyCache.removeAll()
        dayArticlesCache.removeAll()
        cachedMonthOrder.removeAll()
        inFlightPrefetch.removeAll()
        readArticleIds.removeAll()
        lastLoadedDate = nil
        isTodayLoading = false
        isLoaded = false
        latestMonthRequestKey = nil
        latestDateSelectionKey = nil

        let today = Date()
        batchUpdate {
            calendarState.selectedDate = today
            calendarState.displayedMonth = startOfMonth(today)
            calendarState.dataDays = []
            calendarState.isLoading = false
        }
        filteredArticles = []
        subscribedNewsletters = []
        articlesByMonth = []

        if isGuest {
            homeState = .guest
        }
    }

    public func shouldReloadToday(currentDate: Date = Date()) async -> Bool {
        if !isLoaded { return true }
        guard let lastLoadedDate else { return true }
        return !Calendar.current.isDate(lastLoadedDate, inSameDayAs: currentDate)
    }

    public func refreshHighlights() async {
        let updated = await decorateArticlesUseCase.execute(articles: filteredArticles, readIds: readArticleIds)
        let targetDate = calendarState.selectedDate
        withAnimation(.easeInOut(duration: 0.25)) {
            filteredArticles = updated
        }
        storeArticles(updated, for: targetDate)
    }

    public func calendarDataDays(for date: Date) async -> Set<Int> {
        guard !isGuest else { return [] }

        let key = monthKey(for: date)
        if let cached = dataDaysCache[key] {
            return cached
        }

        if let monthly = monthlyCache[key] {
            let days = extractArticleDaysUseCase.execute(from: monthly)
            storeDataDays(days, for: date)
            return days
        }

        return await fetchDataDays(for: date)
    }

    // MARK: - Private: Month Loading

    private func performMonthRequest(for date: Date, forceReload: Bool) async {
        guard !isGuest else {
            calendarState.isLoading = false
            homeState = .guest
            return
        }
        let requestKey = monthKey(for: date)
        latestMonthRequestKey = requestKey
        calendarState.isLoading = true

        await loadMonthInternal(for: date, forceReload: forceReload)
        prefetchAdjacent(from: date)
        guard latestMonthRequestKey == requestKey else { return }

        calendarState.isLoading = false
        await updateFilteredArticles()
        homeState = resolveState()
    }

    private func loadMonthInternal(for date: Date, forceReload: Bool = false) async {
        let key = monthKey(for: date)
        let month = startOfMonth(date)

        if !forceReload, let cached = monthlyCache[key] {
            touchMonthCache(key)
            batchUpdate {
                calendarState.displayedMonth = month
                calendarState.dataDays = dataDaysCache[key] ?? []
            }
            articlesByMonth = cached
            return
        }

        if let cachedDays = dataDaysCache[key] {
            calendarState.dataDays = cachedDays
        }

        do {
            let monthly = try await fetchMonthArticlesUseCase.execute(
                year: formatYear(date),
                publicationMonth: formatMonth(date)
            )
            batchUpdate {
                calendarState.displayedMonth = month
            }
            articlesByMonth = monthly
            monthlyCache[key] = monthly
            let days = extractArticleDaysUseCase.execute(from: monthly)
            storeDataDays(days, for: date)
            calendarState.dataDays = days
            calendarState.isLoading = false
            prefetchAdjacent(from: month)
        } catch {
            if Task.isCancelled { return }
            handleError(error, feature: "home", operation: "loadMonthData")
            calendarState.isLoading = false
        }
    }

    // MARK: - Private: Article Loading & Decoration

    private func updateFilteredArticles(for date: Date? = nil) async {
        let target = date ?? calendarState.selectedDate
        let articles = await loadArticles(for: target)
        withAnimation(.easeInOut(duration: 0.25)) {
            filteredArticles = articles
        }
        applyMonthlyAdjustment(for: target, articles: articles)
    }

    private func loadArticles(for date: Date) async -> [HomeArticle] {
        if let cached = cachedArticles(for: date) {
            return cached
        }

        do {
            let fetched = try await fetchDayArticlesUseCase.execute(
                year: formatYear(date),
                publicationMonth: formatMonth(date),
                publicationDate: formatDay(date)
            )
            let decorated = await decorateArticles(fetched)
            storeArticles(decorated, for: date)
            return decorated
        } catch {
            handleError(error, feature: "home", operation: "loadArticles")
            return []
        }
    }

    private func decorateArticles(_ articles: [HomeArticle], refreshHighlightCounts: Bool = true) async -> [HomeArticle] {
        await decorateArticlesUseCase.execute(articles: articles, readIds: readArticleIds, refreshHighlightCounts: refreshHighlightCounts)
    }

    // MARK: - Private: Cache Management

    private func storeArticles(_ articles: [HomeArticle], for date: Date) {
        dayArticlesCache[dayKey(for: date)] = articles
    }

    private func cachedArticles(for date: Date) -> [HomeArticle]? {
        dayArticlesCache[dayKey(for: date)]
    }

    private func storeDataDays(_ days: Set<Int>, for date: Date) {
        let key = monthKey(for: date)
        dataDaysCache[key] = days
        touchMonthCache(key)
    }

    private func touchMonthCache(_ key: String) {
        cachedMonthOrder.removeAll { $0 == key }
        cachedMonthOrder.append(key)

        let displayedKey = monthKey(for: calendarState.displayedMonth)
        while cachedMonthOrder.count > maxCachedMonths,
              let oldest = cachedMonthOrder.first(where: { $0 != displayedKey }) {
            cachedMonthOrder.removeAll { $0 == oldest }
            evictMonth(oldest)
        }
    }

    private func evictMonth(_ key: String) {
        monthlyCache.removeValue(forKey: key)
        dataDaysCache.removeValue(forKey: key)
        let prefix = "\(key)-"
        dayArticlesCache = dayArticlesCache.filter { !$0.key.hasPrefix(prefix) }
    }

    private func applyMonthlyAdjustment(for date: Date, articles: [HomeArticle]) {
        let day = Calendar.current.component(.day, from: date)
        articlesByMonth = mergeDayArticleSummaryUseCase.execute(day: day, dayArticles: articles, into: articlesByMonth)

        let key = monthKey(for: date)
        if var cache = monthlyCache[key] {
            cache = mergeDayArticleSummaryUseCase.execute(day: day, dayArticles: articles, into: cache)
            monthlyCache[key] = cache
            let days = extractArticleDaysUseCase.execute(from: cache)
            storeDataDays(days, for: date)
            if key == monthKey(for: calendarState.displayedMonth) {
                calendarState.dataDays = days
            }
        } else if key == monthKey(for: calendarState.displayedMonth) {
            let days = extractArticleDaysUseCase.execute(from: articlesByMonth)
            storeDataDays(days, for: date)
            calendarState.dataDays = days
        }
    }

    private func clearMonthlyCache(for date: Date) {
        let key = monthKey(for: date)
        cachedMonthOrder.removeAll { $0 == key }
        evictMonth(key)
    }

    // MARK: - Private: Prefetching

    private func prefetchAdjacent(from date: Date) {
        let calendar = Calendar.current
        for offset in [-1, 1] {
            guard let target = calendar.date(byAdding: .month, value: offset, to: date) else { continue }
            let key = monthKey(for: target)
            if monthlyCache[key] != nil || inFlightPrefetch.contains(key) { continue }
            inFlightPrefetch.insert(key)
            Task { [weak self] in
                await self?.fetchDataDays(for: target)
                self?.inFlightPrefetch.remove(key)
            }
        }
    }

    @discardableResult
    private func fetchDataDays(for date: Date) async -> Set<Int> {
        let key = monthKey(for: date)
        do {
            let monthly = try await fetchMonthArticlesUseCase.execute(
                year: formatYear(date),
                publicationMonth: formatMonth(date)
            )
            monthlyCache[key] = monthly
            let days = extractArticleDaysUseCase.execute(from: monthly)
            storeDataDays(days, for: date)
            return days
        } catch {
            handleError(error, feature: "home", operation: "fetchDataDays")
            return []
        }
    }

    // MARK: - Private: Batch Update Helper

    private func batchUpdate(_ block: () -> Void) {
        isBatchUpdating = true
        defer { isBatchUpdating = false }
        block()
    }

    // MARK: - Private: Date Helpers

    private func formatYear(_ date: Date) -> String { date.newdokYearString }
    private func formatMonth(_ date: Date) -> String { date.newdokMonthString }
    private func formatDay(_ date: Date) -> String { date.newdokDayString }

    private func strippedDate(_ date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private func startOfMonth(_ date: Date) -> Date {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    private func monthKey(for date: Date) -> String { date.newdokMonthKey }
    private func dayKey(for date: Date) -> String { date.newdokDayKey }
}
