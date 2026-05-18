import Foundation

public protocol HomeBusinessUseCase: AnyObject, Sendable {
    func snapshot() async -> HomeSnapshot
    func loadToday() async -> HomeSnapshot
    func loadMonthData(for date: Date, forceReload: Bool) async -> HomeSnapshot
    func loadMonthDataIfNeeded(for date: Date) async -> HomeSnapshot
    func selectDateWithMonthGuarantee(_ date: Date) async -> HomeSnapshot
    func refreshCurrentData() async -> HomeSnapshot
    func refreshToToday() async -> HomeSnapshot
    func markArticleAsRead(articleId: Int) async -> HomeSnapshot
    func refreshHighlightCounts() async -> HomeSnapshot
    func resetForAuthChange() async -> HomeSnapshot
    func shouldReloadToday(currentDate: Date) async -> Bool
    func cachedDataDays(for date: Date) async -> Set<Int>
    func fetchDataDays(for date: Date) async -> Set<Int>
}
