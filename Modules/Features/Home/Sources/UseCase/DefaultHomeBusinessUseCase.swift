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
    private let articleRepository: HomeArticleRepository
    private let newsletterRepository: HomeNewsletterRepository

    private var snapshotState: HomeSnapshot
    private var monthlyCache: [String: [HomeArticles]] = [:]
    private var dataDaysByMonthCache: [String: Set<Int>] = [:]
    private var readArticleIds: Set<Int> = []
    private var lastLoadedDate: Date?
    private var dayArticlesCache: [String: [HomeArticle]] = [:]
    private var isTodayLoading = false

    public init(
        articleRepository: HomeArticleRepository,
        newsletterRepository: HomeNewsletterRepository
    ) {
        self.articleRepository = articleRepository
        self.newsletterRepository = newsletterRepository
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
        // actor의 nonisolated init에서는 isolated 메서드 호출 불가 → inline 처리.
        // 초기화 시점이라 self는 아직 공유되지 않으므로 직접 대입 안전.
        readArticleIds = articleRepository.loadReadArticleIds()
    }

    public func snapshot() async -> HomeSnapshot {
        snapshotState
    }

    public func loadToday() async -> HomeSnapshot {
        if isTodayLoading { return snapshotState }
        isTodayLoading = true
        defer { isTodayLoading = false }

        do {
            async let articlesTask = articleRepository.fetchTodayArticles()
            async let newslettersTask = newsletterRepository.fetchActiveSubscription()
            let articles = try await articlesTask
            let newsletters = try await newslettersTask

            let today = strippedDate(Date())
            let month = startOfMonth(today)
            let processedArticles = decorateTodayArticles(articles, readArticleIds: readArticleIds)

            snapshotState.selectedDate = today
            snapshotState.displayedMonth = month
            snapshotState.subscribedNewsletters = newsletters
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
            try await articleRepository.refresh()
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

        _ = await loadMonthData(for: date)
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
            cached = decorateTodayArticles(cached, readArticleIds: readArticleIds)
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
        try await articleRepository.fetchArticles(year: formatYear(date), publicationMonth: formatMonth(date))
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
            let fetched = try await articleRepository.fetchDayArticles(
                year: formatYear(date),
                publicationMonth: formatMonth(date),
                publicationDate: formatDay(date)
            )
            let decorated = decorateTodayArticles(fetched, readArticleIds: readArticleIds)
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
            unreadCount: unreadCount(in: articles)
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

    // MARK: - Read state decoration

    private func decorateTodayArticles(_ articles: [HomeArticle], readArticleIds: Set<Int>) -> [HomeArticle] {
        let mapped = articles.map { applyReadStatus(to: $0, readArticleIds: readArticleIds) }
        return prioritize(mapped)
    }

    private func unreadCount(in articles: [HomeArticle]) -> Int {
        articles.reduce(into: 0) { count, article in
            if !isRead(article) { count += 1 }
        }
    }

    private func applyReadStatus(to article: HomeArticle, readArticleIds: Set<Int>) -> HomeArticle {
        guard readArticleIds.contains(article.articleId) else { return article }
        return HomeArticle(
            brandName: article.brandName,
            imageUrl: article.imageUrl,
            articleTitle: article.articleTitle,
            articleId: article.articleId,
            status: "Read",
            publishDate: article.publishDate
        )
    }

    private func prioritize(_ articles: [HomeArticle]) -> [HomeArticle] {
        articles.sorted { lhs, rhs in
            let lhsRead = isRead(lhs)
            let rhsRead = isRead(rhs)
            if lhsRead != rhsRead { return !lhsRead }
            return lhs.articleId > rhs.articleId
        }
    }

    private func isRead(_ article: HomeArticle) -> Bool {
        article.status.caseInsensitiveCompare("Read") == .orderedSame
    }

    // MARK: - Date helpers

    private func formatYear(_ date: Date) -> String {
        date.newdokYearString
    }

    private func formatMonth(_ date: Date) -> String {
        date.newdokMonthString
    }

    private func formatDay(_ date: Date) -> String {
        date.newdokDayString
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
        date.newdokMonthKey
    }

    private func dayKey(for date: Date) -> String {
        date.newdokDayKey
    }

    private func clearMonthlyCache(for date: Date) {
        let key = monthKey(for: date)
        monthlyCache.removeValue(forKey: key)
        dataDaysByMonthCache.removeValue(forKey: key)
        let prefix = "\(key)-"
        dayArticlesCache = dayArticlesCache.filter { !$0.key.hasPrefix(prefix) }
    }

    private func loadReadArticleIds() {
        readArticleIds = articleRepository.loadReadArticleIds()
    }

    private func saveReadArticleIds() {
        articleRepository.saveReadArticleIds(readArticleIds)
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
