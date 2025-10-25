//
//  HomeViewModel.swift
//  Home
//
//  Created by 권민재 on 4/16/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import Combine
import Domain
import Shared
import Foundation
import Core

// MARK: - Calendar State Management
@MainActor
public final class CalendarState: ObservableObject {
    @Published public var selectedDate: Date
    @Published public var displayedMonth: Date
    @Published public var dataDays: Set<Int> = []
    @Published public var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(initialDate: Date = Date()) {
        self.selectedDate = initialDate
        self.displayedMonth = initialDate
    }
    
    // Combine 기반 반응형 업데이트
    public func bind(to viewModel: HomeViewModel) {
        // 월 변경 감지 → 캐시 먼저 적용, 없으면 로드
        $displayedMonth
            .removeDuplicates { Calendar.current.isDate($0, equalTo: $1, toGranularity: .month) }
            .dropFirst() // 초기값 무시
            .sink { [weak viewModel] newMonth in
                Task { @MainActor in
                    guard let vm = viewModel else { return }
                    
                    // 1) 캐시된 점 데이터 즉시 적용
                    vm.applyDataDaysForMonth(newMonth)
                    
                    // 2) 신규 데이터 로드
                    await vm.loadMonthData(for: newMonth)
                }
            }
            .store(in: &cancellables)
    }
}

enum HomeState {
    case none
    case guest
    case noSubscriptions
    case noArticles
    case articles
}

@MainActor
public final class HomeViewModel: ObservableObject {
    
    private let useCase: FetchHomeDataUseCase
    
    // 중첩 ObservableObject
    @Published public var calendarState: CalendarState
    
    // 🔗 브리지용
    private var cancellables = Set<AnyCancellable>()
    
    public init(useCase: FetchHomeDataUseCase) {
        self.useCase = useCase
        self.calendarState = CalendarState()
        
        // 읽음 상태 로드
        loadReadArticleIds()
        
        // CalendarState 변경을 HomeViewModel 변경으로 브리지
        calendarState.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        // CalendarState와 ViewModel 바인딩
        calendarState.bind(to: self)
    }
    
    // MARK: - Published Properties
    @Published public var isLoaded: Bool = false
    @Published public var filteredArticles: [Article] = []
    @Published public var subscribedNewsletters: [Newsletter] = []
    @Published public var articlesByMonth: [Articles] = []
    
    // MARK: - Cache
    private var monthlyCache: [String: [Articles]] = [:]
    private var dataDaysByMonthCache: [String: Set<Int>] = [:]
    private var loadingTasks: [String: Task<Void, Never>] = [:]
    
    // 읽음 상태 영구 저장
    private let readArticlesKey = "readArticles"
    private var readArticleIds: Set<Int> = []
    private var isTodayLoading = false
    private var lastLoadedDate: Date?
    private var cachedTodayArticles: [Article]?
    private var cachedTodayDate: Date?
    
    // MARK: - Computed Properties
    public var selectedDate: Date {
        get { calendarState.selectedDate }
        set { calendarState.selectedDate = newValue }
    }
    
    public var displayedMonth: Date {
        get { calendarState.displayedMonth }
        set { calendarState.displayedMonth = newValue }
    }
    
    public func updateCalendarData(_ data: [Articles]) {
        self.articlesByMonth = data
        self.updateDataDays()
    }
    
    // 점 데이터 업데이트 (실제 아티클이 있는 날만)
    private func updateDataDays() {
        let daysWithArticles = articlesByMonth
            .filter { !$0.receivedArticleList.isEmpty }
            .map { $0.publishDate }
        
        let newDataDays = Set(daysWithArticles)
        calendarState.dataDays = newDataDays
        
        // 현재 월 캐시에 저장
        let key = monthKey(for: calendarState.displayedMonth)
        dataDaysByMonthCache[key] = newDataDays
    }

    public func selectDate(_ day: Int) {
        if let articles = articlesByMonth.first(where: { $0.publishDate == day })?.receivedArticleList {
            self.filteredArticles = articles
        }
    }
    
    // 날짜 선택: 월은 그대로, 데이터 로드+필터
    public func selectDateWithMonthGuarantee(_ date: Date) {
        let calendar = Calendar.current
        let selectedDay = calendar.component(.day, from: date)
        logDebug("날짜 선택: \(date)", category: .home)
        calendarState.selectedDate = date
        
        Task {
            await loadMonthData(for: date)
            self.selectDate(selectedDay)
        }
    }
    
    @AppStorage("isGuest") public var isGuest: Bool = false
    
    public var articlesByMonthDates: Set<Date> {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        return Set(articlesByMonth.compactMap { group in
            guard group.receivedUnread > 0 else { return nil }
            var dc = comps
            dc.day = group.publishDate
            return calendar.date(from: dc)
        })
    }
    
    var homeState: HomeState {
        if isGuest { return .guest }
        if !isLoaded { return .none }
        if subscribedNewsletters.isEmpty && filteredArticles.isEmpty { return .noSubscriptions }
        if subscribedNewsletters.isEmpty && !filteredArticles.isEmpty { return .noSubscriptions }
        if filteredArticles.isEmpty { return .noArticles }
        return .articles
    }
    
    public var activeArticeDays: [Int] {
        articlesByMonth
            .filter { $0.receivedUnread > 0 }
            .map { $0.publishDate }
    }
    
    // MARK: - Data Loading Methods
    public func loadToday() async {
        if isTodayLoading { return }
        isTodayLoading = true
        defer { isTodayLoading = false }
        
        logInfo("오늘 데이터 로드 시작", category: .home)
        var tempArticles: [Article] = []
        var tempNewsletters: [Newsletter] = []
        
        do {
            // 1) 오늘 데이터(구독/아티클)
            let data = try await useCase.fetchTodayData()
            tempArticles = data.articles
            tempNewsletters = data.activeNewsletters
            logDebug("오늘 데이터 로드 완료 - 아티클: \(tempArticles.count)개, 뉴스레터: \(tempNewsletters.count)개", category: .home)
            
            // 2) 오늘 날짜로 캘린더 리셋 (명시적으로 현재 시간 사용)
            let today = Date()
            let calendar = Calendar.current
            let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
            let todayDate = calendar.date(from: todayComponents) ?? today
            
            // UI 업데이트를 위해 MainActor에서 실행
            await MainActor.run {
                self.calendarState.selectedDate = todayDate
                self.calendarState.displayedMonth = calendar.date(
                    from: calendar.dateComponents([.year, .month], from: todayDate)
                ) ?? todayDate
                self.lastLoadedDate = todayDate
                logDebug("오늘 날짜 설정: \(todayDate)", category: .home)
            }
            
            // 3) 월 데이터 로드 (없으면 가져오고, 있으면 캐시 사용)
            clearMonthlyCache(for: todayDate)
            await loadMonthData(for: todayDate, forceReload: true)
            
            // 3.5) 백그라운드 웜업 (올해 1월 ~ 현재 달)
            warmupCurrentYear(for: todayDate)
            
            // 4) 읽음 상태 복원 및 월 데이터 캐시에 오늘 데이터 반영 후 UI 업데이트
            await MainActor.run {
                // 읽음 상태 반영 및 정렬 처리
                let processedArticles = self.useCase.decorateTodayArticles(tempArticles, readArticleIds: self.readArticleIds)
                self.cachedTodayArticles = processedArticles
                self.cachedTodayDate = todayDate
                
                // 오늘 데이터만 갱신 (월 캐시/상태 동기화)
                self.updateTodayArticlesCache(with: processedArticles, for: todayDate)
                
                let calendar = Calendar.current
                let selectedDay = calendar.component(.day, from: self.calendarState.selectedDate)
                let dayArticles = self.articlesByMonth
                    .first(where: { $0.publishDate == selectedDay })?
                    .receivedArticleList ?? processedArticles
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.subscribedNewsletters = tempNewsletters
                    self.filteredArticles = dayArticles
                }
                
                self.isLoaded = true
            }
            
        } catch {
            logError("오늘 데이터 로드 실패: \(error.localizedDescription)", category: .home)
            await MainActor.run { self.isLoaded = true }
        }
    }
    
    public func shouldReloadToday(currentDate: Date = Date()) -> Bool {
        if !isLoaded { return true }
        guard let lastLoadedDate else { return true }
        return !Calendar.current.isDate(lastLoadedDate, inSameDayAs: currentDate)
    }

    // 인증 상태 변경 시 초기화
    public func resetForAuthChange() {
        // 진행 중인 작업 취소
        for (_, task) in loadingTasks { task.cancel() }
        loadingTasks.removeAll()

        // 캐시 초기화
        monthlyCache.removeAll()
        dataDaysByMonthCache.removeAll()

        // 상태 초기화
        isLoaded = false
        articlesByMonth = []
        filteredArticles = []
        subscribedNewsletters = []
        calendarState.dataDays = []
        calendarState.isLoading = false

        // 오늘로 리셋
        let today = Date()
        calendarState.selectedDate = today
        calendarState.displayedMonth = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: today)
        ) ?? today
        lastLoadedDate = nil
        cachedTodayArticles = nil
        cachedTodayDate = nil
    }
    
    // MARK: - 스마트 웜업 (올해 1월 ~ 현재 달까지만)
    public func warmupCurrentYear(for date: Date) {
        logInfo("캘린더 웜업 시작 - 올해 1월부터 현재 달까지", category: .cache)
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: date)
            let currentMonth = calendar.component(.month, from: date)
            
            // 올해 1월부터 현재 달까지만 웜업
            for month in 1...currentMonth {
                if Task.isCancelled { return }
                
                var components = DateComponents()
                components.year = currentYear
                components.month = month
                components.day = 1
                
                if let monthDate = calendar.date(from: components) {
                    await self.loadMonthDataSilently(for: monthDate)
                }
                
                // 너무 빠르게 요청하지 않도록 약간의 딜레이
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초
            }
            
            await MainActor.run {
                logInfo("캘린더 웜업 완료 - \(currentMonth)개월 로드됨", category: .cache)
            }
        }
    }
    
    // 조용히 로드 (UI 업데이트 없이 캐시만)
    private func loadMonthDataSilently(for date: Date) async {
        let key = monthKey(for: date)
        
        // 이미 캐시 있으면 스킵
        if monthlyCache[key] != nil {
            return
        }
        
        do {
            let monthly = try await useCase.fetchMonthlyData(
                year: formatYear(date),
                month: formatMonth(date)
            )
            
            let monthlyProcessed = self.useCase.decorateMonthlyArticles(monthly, readArticleIds: self.readArticleIds)
            
            await MainActor.run {
                // 캐시에만 저장 (UI 업데이트 X)
                let mergedMonthly = self.mergeTodayCache(into: monthlyProcessed, for: date)
                self.monthlyCache[key] = mergedMonthly
                
                // 점 데이터 캐시
                let days = Set(mergedMonthly
                    .filter { !$0.receivedArticleList.isEmpty }
                    .map { $0.publishDate })
                self.dataDaysByMonthCache[key] = days
            }
        } catch {
            // 조용히 실패 (에러 무시)
        }
    }
    
    // MARK: - 월 데이터 로딩 (온디맨드)
    // 캐시 있으면 즉시 적용, 없으면 로드
    public func loadMonthDataIfNeeded(for date: Date) async {
        let key = monthKey(for: date)
        
        if let cached = monthlyCache[key] {
            // 캐시 있으면 즉시 적용
            await MainActor.run {
                self.articlesByMonth = cached
                self.updateDataDays()
                self.filterArticles(by: self.calendarState.selectedDate)
            }
        } else {
            // 캐시 없으면 로드
            await loadMonthData(for: date)
        }
    }
    
    public func loadMonthData(for date: Date, forceReload: Bool = false) async {
        let key = monthKey(for: date)
        logDebug("월 데이터 로드 시작: \(key) - forceReload: \(forceReload)", category: .home)
        
        // 이미 로딩 중이면 취소
        if let existingTask = loadingTasks[key] {
            existingTask.cancel()
            loadingTasks.removeValue(forKey: key)
        }
        
        // 캐시가 있으면 즉시 사용
        if !forceReload, let cached = monthlyCache[key] {
            logDebug("캐시된 월 데이터 사용: \(key)", category: .cache)
            await MainActor.run {
                self.articlesByMonth = cached
                self.updateDataDays()
                self.filterArticles(by: self.calendarState.selectedDate)
                self.calendarState.isLoading = false
            }
            return
        }
        
        // 캐시된 점 데이터가 있으면 먼저 표시
        if let cachedDays = dataDaysByMonthCache[key] {
            await MainActor.run {
                self.calendarState.dataDays = cachedDays
            }
        }
        
        // 로딩 시작
        await MainActor.run {
            self.calendarState.isLoading = true
        }
        
        let task = Task {
            do {
                let monthly = try await useCase.fetchMonthlyData(
                    year: formatYear(date),
                    month: formatMonth(date)
                )
                
                if Task.isCancelled { return }
                
                let monthlyProcessed = self.useCase.decorateMonthlyArticles(monthly, readArticleIds: self.readArticleIds)
                
                await MainActor.run {
                    let monthlyWithToday = self.mergeTodayCache(into: monthlyProcessed, for: date)
                    // 캐시 저장
                    self.monthlyCache[key] = monthlyWithToday
                    self.articlesByMonth = monthlyWithToday
                    
                    // 점 데이터 업데이트
                    self.updateDataDays()
                    
                    // 선택된 날짜 필터링
                    self.filterArticles(by: self.calendarState.selectedDate)
                    
                    self.calendarState.isLoading = false
                    logDebug("월 데이터 로드 완료: \(key) - \(monthlyProcessed.count)일", category: .home)
                }
            } catch {
                if !Task.isCancelled {
                    logError("월 데이터 로드 실패: \(key) - \(error.localizedDescription)", category: .home)
                    await MainActor.run {
                        self.calendarState.isLoading = false
                    }
                }
            }
        }
        
        loadingTasks[key] = task
        await task.value
        loadingTasks.removeValue(forKey: key)
        
        // 로드 완료 후 올해 웜업 (현재 달이 올해인 경우만)
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let targetYear = calendar.component(.year, from: date)
        
        if targetYear == currentYear {
            warmupCurrentYear(for: date)
        }
    }
    
    // 상세 → 홈 복귀 시 현재 선택 유지
    public func refreshCurrentData() async {
        filterArticles(by: selectedDate)
    }
    
    // Pull to Refresh 시 오늘 날짜로 강제 이동
    public func refreshToToday() async {
        if isTodayLoading { return }
        let today = Date()
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let todayDate = calendar.date(from: todayComponents) ?? today
        
        await MainActor.run {
            self.calendarState.selectedDate = todayDate
            self.calendarState.displayedMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: todayDate)
            ) ?? todayDate
        }
        
        await loadToday()
    }
    
    // 캘린더에서 월 변경 시 점 데이터 조회
    public func applyDataDaysForMonth(_ date: Date) {
        let key = monthKey(for: date)
        if let cachedDays = dataDaysByMonthCache[key] {
            calendarState.dataDays = cachedDays
        } else {
            // 캐시 없으면 빈 배열 (loadMonthData가 자동으로 호출됨)
            calendarState.dataDays = []
        }
    }
    
 
    // MARK: - 읽음 상태 관리
    private func loadReadArticleIds() {
        if let data = UserDefaults.standard.data(forKey: readArticlesKey),
           let ids = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            readArticleIds = ids
            logDebug("읽음 상태 로드: \(readArticleIds.count)개", category: .article)
        }
    }
    
    private func saveReadArticleIds() {
        if let data = try? JSONEncoder().encode(readArticleIds) {
            UserDefaults.standard.set(data, forKey: readArticlesKey)
            logDebug("읽음 상태 저장: \(readArticleIds.count)개", category: .article)
        }
    }
    
    // MARK: - 필터/읽음 처리
    public func filterArticles(by date: Date) {
        let day = Calendar.current.component(.day, from: date)
        self.filteredArticles = articlesByMonth
            .first(where: { $0.publishDate == day })?
            .receivedArticleList ?? []
    }
    
    public func markArticleAsRead(articleId: Int) {
        logDebug("아티클 읽음 처리: ID \(articleId)", category: .article)
        // 읽음 상태를 영구 저장에 추가
        readArticleIds.insert(articleId)
        saveReadArticleIds()
        
        articlesByMonth = useCase.decorateMonthlyArticles(articlesByMonth, readArticleIds: readArticleIds)
        updateDataDays()
        
        let cacheKey = monthKey(for: calendarState.displayedMonth)
        monthlyCache[cacheKey] = articlesByMonth
        dataDaysByMonthCache[cacheKey] = calendarState.dataDays
        
        if let cachedDate = lastLoadedDate {
            let calendar = Calendar.current
            let day = calendar.component(.day, from: cachedDate)
            if let todayEntry = articlesByMonth.first(where: { $0.publishDate == day }) {
                cachedTodayArticles = todayEntry.receivedArticleList
                cachedTodayDate = cachedDate
            }
        }
        
        filterArticles(by: selectedDate)
    }
    
    // MARK: - 날짜 포맷터
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일(E)"
        return formatter.string(from: selectedDate)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    public func formatYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    public func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter.string(from: date)
    }
    
    // MARK: - 점 데이터 조회 (캐시만)
    public func getDataDaysForMonth(_ date: Date) -> Set<Int> {
        let key = monthKey(for: date)
        return dataDaysByMonthCache[key] ?? []
    }
    
    // 월 키 생성 헬퍼
    public func monthKey(for date: Date) -> String {
        return "\(formatYear(date))-\(formatMonth(date))"
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
        let unread = useCase.unreadCount(in: cachedArticles)
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
        cachedTodayArticles = articles
        cachedTodayDate = date
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let unreadCount = useCase.unreadCount(in: articles)
        let todayEntry = Articles(
            publishDate: day,
            receivedUnread: unreadCount,
            receivedArticleList: articles
        )
        let key = monthKey(for: date)
        
        var updatedMonthData = articlesByMonth
        if let index = updatedMonthData.firstIndex(where: { $0.publishDate == day }) {
            updatedMonthData[index] = todayEntry
        } else {
            updatedMonthData.append(todayEntry)
            updatedMonthData.sort { $0.publishDate < $1.publishDate }
        }
        
        articlesByMonth = updatedMonthData
        updateDataDays()
        
        monthlyCache[key] = updatedMonthData
        dataDaysByMonthCache[key] = calendarState.dataDays
    }
    
    private func clearMonthlyCache(for date: Date) {
        let key = monthKey(for: date)
        if let existingTask = loadingTasks[key] {
            existingTask.cancel()
            loadingTasks.removeValue(forKey: key)
        }
        monthlyCache.removeValue(forKey: key)
        dataDaysByMonthCache.removeValue(forKey: key)
    }
    
}
