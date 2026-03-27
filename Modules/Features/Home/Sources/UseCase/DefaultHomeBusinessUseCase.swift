import Foundation
import HomeDomain
import Shared

private func logHomeError(_ error: Error, operation: String) {
    let context = ErrorContext(
        underlyingError: error,
        feature: "home",
        operation: operation
    )
    ErrorLoggerRegistry.shared?.logError(context)
}

public actor DefaultHomeBusinessUseCase: HomeBusinessUseCase {
    private enum Constants {
        static let readArticlesKey = "readArticles"
    }

    private static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter
    }()

    private let fetchUseCase: FetchHomeDataUseCase

    private var snapshotState: HomeSnapshot
    private var monthlyCache: [String: [HomeArticles]] = [:]
    private var dataDaysByMonthCache: [String: Set<Int>] = [:]
    private var readArticleIds: Set<Int> = []
    private var lastLoadedDate: Date?
    private var dayArticlesCache: [String: [HomeArticle]] = [:]
    private var isTodayLoading = false

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

            snapshotState.selectedDate = today
            snapshotState.displayedMonth = month
            snapshotState.subscribedNewsletters = data.activeNewsletters
            storeArticles(processedArticles, for: today)

            clearMonthlyCache(for: today)
            _ = await loadMonthData(for: today, forceReload: true)
            await updateFilteredArticles(for: today)
            snapshotState.isLoaded = true
            lastLoadedDate = today
        } catch {
            logHomeError(error, operation: "loadToday")
            snapshotState.isLoaded = true
            snapshotState.isCalendarLoading = false
        }
        return snapshotState
    }

    public func refreshToToday() async -> HomeSnapshot {
        do {
            try await fetchUseCase.refresh()
        } catch {
            logHomeError(error, operation: "refresh")
        }
        return await loadToday()
    }

    public func loadMonthData(for date: Date, forceReload: Bool = false) async -> HomeSnapshot {
        let key = monthKey(for: date)
        let month = startOfMonth(date)

        if !forceReload, let cached = monthlyCache[key] {
            snapshotState.displayedMonth = month
            snapshotState.articlesByMonth = cached
            snapshotState.dataDays = dataDaysByMonthCache[key] ?? []
            await updateFilteredArticles()
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
            updateDataDays(with: monthly, forKey: key)
            snapshotState.isCalendarLoading = false
            monthlyCache[key] = monthly
            await updateFilteredArticles()
            prefetchAdjacentMonths(from: month)
        } catch {
            if Task.isCancelled { return snapshotState }
            logHomeError(error, operation: "loadMonthData")
            snapshotState.isCalendarLoading = false
        }

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
            await updateFilteredArticles(for: date)
            return snapshotState
        }

        await loadMonthData(for: date)
        await updateFilteredArticles(for: date)
        return snapshotState
    }

    public func refreshCurrentData() async -> HomeSnapshot {
        await updateFilteredArticles()
        return snapshotState
    }

    public func markArticleAsRead(articleId: Int) async -> HomeSnapshot {
        readArticleIds.insert(articleId)
        saveReadArticleIds()

        let targetDate = snapshotState.selectedDate
        if var cached = cachedArticles(for: targetDate) {
            cached = fetchUseCase.decorateTodayArticles(cached, readArticleIds: readArticleIds)
            storeArticles(cached, for: targetDate)
            snapshotState.filteredArticles = cached
            applyMonthlyAdjustment(for: targetDate, articles: cached)
        } else {
            await updateFilteredArticles(for: targetDate)
        }
        return snapshotState
    }

    public func resetForAuthChange() async -> HomeSnapshot {
        monthlyCache.removeAll()
        dataDaysByMonthCache.removeAll()
        lastLoadedDate = nil
        dayArticlesCache.removeAll()
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

    public func fetchDataDays(for date: Date) async -> Set<Int> {
        let key = monthKey(for: date)
        if let cached = dataDaysByMonthCache[key] {
            return cached
        }

        do {
            let monthly = try await fetchMonthly(for: date)
            monthlyCache[key] = monthly
            updateDataDays(with: monthly, forKey: key, affectsSnapshot: false)
        } catch {
            logHomeError(error, operation: "fetchDataDays")
            return []
        }

        return dataDaysByMonthCache[key] ?? []
    }

    // MARK: - Helpers
    private func fetchMonthly(for date: Date) async throws -> [HomeArticles] {
        try await fetchUseCase.fetchMonthlyData(
            year: formatYear(date),
            month: formatMonth(date)
        )
    }

    private func updateDataDays(with monthly: [HomeArticles], forKey key: String, affectsSnapshot: Bool = true) {
        let days = Set(
            monthly
                .filter { $0.hasArticles }
                .map { $0.publishDate }
        )
        if affectsSnapshot, key == monthKey(for: snapshotState.displayedMonth) {
            snapshotState.dataDays = days
        }
        dataDaysByMonthCache[key] = days
    }

    private func updateFilteredArticles(for date: Date? = nil) async {
        let target = date ?? snapshotState.selectedDate
        let articles = await loadArticles(for: target)
        snapshotState.filteredArticles = articles
        applyMonthlyAdjustment(for: target, articles: articles)
    }

    private func loadArticles(for date: Date) async -> [HomeArticle] {
        if let cached = cachedArticles(for: date) {
            return cached
        }

        do {
            let fetched = try await fetchUseCase.fetchDayArticles(
                year: formatYear(date),
                month: formatMonth(date),
                day: formatDay(date)
            )
            let decorated = fetchUseCase.decorateTodayArticles(fetched, readArticleIds: readArticleIds)
            storeArticles(decorated, for: date)
            return decorated
        } catch {
            logHomeError(error, operation: "loadArticles")
            return []
        }
    }

    private func storeArticles(_ articles: [HomeArticle], for date: Date) {
        dayArticlesCache[dayKey(for: date)] = articles
    }

    private func cachedArticles(for date: Date) -> [HomeArticle]? {
        dayArticlesCache[dayKey(for: date)]
    }

    private func applyMonthlyAdjustment(for date: Date, articles: [HomeArticle]) {
        let day = Calendar.current.component(.day, from: date)
        let entry = HomeArticles(
            publishDate: day,
            hasArticles: !articles.isEmpty,
            totalCount: articles.count,
            unreadCount: fetchUseCase.unreadCount(in: articles)
        )

        replaceEntry(entry, in: &snapshotState.articlesByMonth)

        let key = monthKey(for: date)
        if var cache = monthlyCache[key] {
            replaceEntry(entry, in: &cache)
            monthlyCache[key] = cache
            updateDataDays(with: cache, forKey: key, affectsSnapshot: key == monthKey(for: snapshotState.displayedMonth))
        } else if key == monthKey(for: snapshotState.displayedMonth) {
            updateDataDays(with: snapshotState.articlesByMonth, forKey: key)
        }
    }

    private func replaceEntry(_ entry: HomeArticles, in list: inout [HomeArticles]) {
        if let index = list.firstIndex(where: { $0.publishDate == entry.publishDate }) {
            list[index] = entry
        } else {
            list.append(entry)
            list.sort { $0.publishDate < $1.publishDate }
        }
    }

    private func formatYear(_ date: Date) -> String {
        Self.yearFormatter.string(from: date)
    }

    private func formatMonth(_ date: Date) -> String {
        Self.monthFormatter.string(from: date)
    }

    private func formatDay(_ date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        return String(format: "%02d", day)
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

    private func dayKey(for date: Date) -> String {
        "\(monthKey(for: date))-\(formatDay(date))"
    }

    private func clearMonthlyCache(for date: Date) {
        let key = monthKey(for: date)
        monthlyCache.removeValue(forKey: key)
        dataDaysByMonthCache.removeValue(forKey: key)
        let prefix = "\(key)-"
        dayArticlesCache = dayArticlesCache.filter { !$0.key.hasPrefix(prefix) }
    }

    private func loadReadArticleIds() {
        if
            let data = UserDefaults.standard.data(forKey: Constants.readArticlesKey),
            let ids = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            readArticleIds = ids
        }
    }

    private func saveReadArticleIds() {
        if let data = try? JSONEncoder().encode(readArticleIds) {
            UserDefaults.standard.set(data, forKey: Constants.readArticlesKey)
        }
    }

    private func prefetchAdjacentMonths(from date: Date) {
        let calendar = Calendar.current
        for offset in [-1, 1] {
            guard let target = calendar.date(byAdding: .month, value: offset, to: date) else { continue }
            Task.detached { [weak self] in
                await self?.prefetchMonthIfNeeded(for: target)
            }
        }
    }

    private func prefetchMonthIfNeeded(for date: Date) async {
        let key = monthKey(for: date)
        if monthlyCache[key] != nil { return }

        do {
            let monthly = try await fetchMonthly(for: date)
            monthlyCache[key] = monthly
            updateDataDays(with: monthly, forKey: key, affectsSnapshot: false)
        } catch {
            logHomeError(error, operation: "prefetchMonth")
        }
    }
}
