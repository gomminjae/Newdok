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

// MARK: - Calendar State Management
@MainActor
public final class CalendarState: ObservableObject {
    @Published public var selectedDate: Date = Date()
    @Published public var displayedMonth: Date = Date()
    @Published public var dataDays: Set<Int> = []
    @Published public var isLoading: Bool = false
    
    public init() {
        displayedMonth = selectedDate
    }
    
    public func updateSelectedDate(_ date: Date) {
        selectedDate = date
    }
    
    public func updateDisplayedMonth(_ date: Date) {
        displayedMonth = date
    }
    
    public func updateDataDays(_ days: Set<Int>) {
        dataDays = days
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
        self.dataDays = []
        
        // 읽음 상태 로드
        loadReadArticleIds()
        
        // 초기화 시 별도 로딩 제거 - onAppear에서 loadToday()로 통합
        
        // 🔗 옵션 A: calendarState 변경을 HomeViewModel 변경으로 브리지
        calendarState.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    @Published public var isLoaded: Bool = false
    @Published public var filteredArticles: [Article] = []
    @Published public var subscribedNewsletters: [Newsletter] = []
    @Published public var articlesByMonth: [Articles] = []
    @Published public var monthlyCache: [String: [Articles]] = [:]
    // "yyyy-MM" → Set<Int>
    @Published private var dataDaysByMonthCache: [String: Set<Int>] = [:]
    
    private var isWarmingCache: Bool = false
    private var warmedYears: Set<Int> = []
    @Published var currentMonthKey: String = ""
    @Published public var dataDays: Set<Int> = []
    @Published public var onMonthChanged: ((Date) -> Void)?
    @Published public var isLoadingMonth: Bool = false
    private var latestRequestKey: String = ""
    private var loadingTasks: [String: Task<Void, Never>] = [:]
    private var warmupRootTask: Task<Void, Never>?
    
    // 읽음 상태 영구 저장을 위한 UserDefaults 키
    private let readArticlesKey = "readArticles"
    private var readArticleIds: Set<Int> = []
    
    // 캐시 업데이트 시 현재 표시 중인 월 확인
    private func checkAndUpdateCurrentMonth() {
        let currentKey = "\(formatYear(displayedMonth))-\(formatMonth(displayedMonth))"
        
        if let cachedDays = dataDaysByMonthCache[currentKey] {
            self.dataDays = cachedDays
            self.calendarState.updateDataDays(cachedDays)
        } else {
        }
    }
    
    // MARK: - Computed Properties
    public var selectedDate: Date {
        get { calendarState.selectedDate }
        set { calendarState.updateSelectedDate(newValue) }
    }
    
    public var displayedMonth: Date {
        get { calendarState.displayedMonth }
        set { calendarState.updateDisplayedMonth(newValue) }
    }
    
    public func updateCalendarData(_ data: [Articles]) {
        self.articlesByMonth = data
        self.updateDataDays()
    }
    
    private func updateDataDays() {
        // 읽음 여부와 무관: 리스트가 존재하면 점 표시
        let daysWithArticles = articlesByMonth.filter { !$0.receivedArticleList.isEmpty }
        let newDataDays = Set(daysWithArticles.map { $0.publishDate })
        
        // 디버깅
        for article in articlesByMonth.sorted(by: { $0.publishDate < $1.publishDate }) {
            if !article.receivedArticleList.isEmpty {
                print("  ✅ \(article.publishDate)일: 아티클 \(article.receivedArticleList.count)개")
            } else {
                print("  ❌ \(article.publishDate)일: 아티클 없음")
            }
        }
        
        // 캘린더 상태와 동기화
        self.dataDays = newDataDays
        self.calendarState.updateDataDays(newDataDays)
        if !currentMonthKey.isEmpty {
            dataDaysByMonthCache[currentMonthKey] = newDataDays
        }
    }

    private func applyDotsIfMatches(key: String, days: Set<Int>) {
        let currentKey = "\(formatYear(displayedMonth))-\(formatMonth(displayedMonth))"
        if currentKey == key {
            self.dataDays = days
            self.calendarState.updateDataDays(days)
        }
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
        print("📅 [HomeViewModel] 날짜 선택: \(date)")
        calendarState.selectedDate = date
        
        Task {
            await loadArticles(for: date)
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
        var tempArticles: [Article] = []
        var tempNewsletters: [Newsletter] = []
        
        do {
            // 1) 오늘 데이터(구독/아티클)
            let data = try await useCase.fetchTodayData()
            tempArticles = data.articles
            tempNewsletters = data.activeNewsletters
            
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
                print("📅 [HomeViewModel] 오늘 날짜 설정: \(todayDate)")
            }
            
            // 3) 월 데이터 로드
            await loadArticles(for: todayDate)
            
            // 4) 읽음 상태 복원 후 UI 업데이트 + isLoaded 지연
            await MainActor.run {
                // 읽음 상태 복원
                let articlesWithReadStatus = self.applyReadStatusToArticles(tempArticles)
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.filteredArticles = articlesWithReadStatus
                    self.subscribedNewsletters = tempNewsletters
                }
                
                // 오늘 날짜로 필터링 강제 적용
                self.filterArticles(by: self.calendarState.selectedDate)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.isLoaded = true
                }
            }
            
            // 5) 백그라운드 캐싱
            startWarmup(for: today)
        } catch {
            print("today fetch error: \(error)")
            await MainActor.run { self.isLoaded = true }
        }
    }

    // MARK: - 워밍업 제어
    public func startWarmup(for date: Date) {
        warmupRootTask?.cancel()
        warmupRootTask = Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            if Task.isCancelled { return }
            try? await Task.sleep(nanoseconds: 100_000_000)
            if Task.isCancelled { return }
            await self.warmupYearCache(for: date)
            if Task.isCancelled { return }
            let lastYear = Calendar.current.component(.year, from: date) - 1
            await self.warmupYearCache(year: lastYear, targetMonth: 12)
        }
    }

    public func cancelWarmups() {
        warmupRootTask?.cancel()
        warmupRootTask = nil
    }

    // 인증 상태 변경 시 초기화
    public func resetForAuthChange() {
        for (_, task) in loadingTasks { task.cancel() }
        loadingTasks.removeAll()
        latestRequestKey = ""

        isWarmingCache = false
        warmedYears.removeAll()
        monthlyCache.removeAll()
        dataDaysByMonthCache.removeAll()

        articlesByMonth = []
        filteredArticles = []
        subscribedNewsletters = []
        dataDays = []
        currentMonthKey = ""
        isLoadingMonth = false
        calendarState.isLoading = false
        isLoaded = false

        let today = Date()
        calendarState.selectedDate = today
        calendarState.displayedMonth = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: today)
        ) ?? today
    }
    
    // MARK: - 워밍업 구현
    private func warmupYearCache(for date: Date) async {
        if isWarmingCache { return }
        isWarmingCache = true
        defer { isWarmingCache = false }

        let cal = Calendar.current
        let year = Int(formatYear(date)) ?? cal.component(.year, from: date)
        let currentMonth = cal.component(.month, from: date)
        warmedYears.insert(year)
        print("🔥 [HomeViewModel] Task Group 워밍업 시작: \(year)년 1..\(currentMonth)월")
        
        let months = Array(1...currentMonth)
        let chunkSize = 3
        for start in stride(from: 0, to: months.count, by: chunkSize) {
            if Task.isCancelled { return }
            let end = min(start + chunkSize, months.count)
            let chunk = months[start..<end]
            await withTaskGroup(of: (String, Result<[Articles], Error>).self) { group in
                for month in chunk {
                    let monthStr = String(format: "%02d", month)
                    let key = "\(year)-\(monthStr)"
                    if monthlyCache[key] != nil {
                        print("🔥 [HomeViewModel] 이미 캐시됨: \(key)")
                        continue
                    }
                    group.addTask {
                        if Task.isCancelled { return (key, .failure(CancellationError())) }
                        print("🔥 [HomeViewModel] Task 시작: \(key)")
                        do {
                            let monthly = try await self.useCase.fetchMonthlyData(year: String(year), month: monthStr)
                            print("🔥 [HomeViewModel] Task 완료: \(key), 아티클 수: \(monthly.count)")
                            return (key, .success(monthly))
                        } catch {
                            print("⚠️ [HomeViewModel] Task 실패: \(key), error=\(error)")
                            return (key, .failure(error))
                        }
                    }
                }
                for await (key, result) in group {
                    switch result {
                    case .success(let monthly):
                        await MainActor.run {
                            self.monthlyCache[key] = monthly
                            let days = Set(monthly.filter { !$0.receivedArticleList.isEmpty }.map { $0.publishDate })
                            self.dataDaysByMonthCache[key] = days
                            print("🔥 [HomeViewModel] Task Group 캐시 저장: \(key), days=\(days.sorted())")
                            self.applyDotsIfMatches(key: key, days: days)
                        }
                    case .failure(let error):
                        print("⚠️ [HomeViewModel] Task Group 캐시 저장 실패: \(key), error=\(error)")
                    }
                }
            }
        }
        print("✅ [HomeViewModel] Task Group 워밍업 완료")
    }

    private func warmupYearCache(year: Int, targetMonth: Int) async {
        if warmedYears.contains(year) {
            print("🔥 [HomeViewModel] 이미 워밍업된 연도: \(year)")
            return
        }
        let months = max(1, min(12, targetMonth))
        let currentYear = Calendar.current.component(.year, from: Date())
        let isPastYear = year < currentYear
        
        print("🔥 [HomeViewModel] 지정 연도 Task Group 워밍업 시작: \(year)년 1..\(months)월 (작년: \(isPastYear))")
        
        let monthList = Array(1...months)
        let chunkSize = 3
        for start in stride(from: 0, to: monthList.count, by: chunkSize) {
            if Task.isCancelled { return }
            let end = min(start + chunkSize, monthList.count)
            let chunk = monthList[start..<end]
            await withTaskGroup(of: (String, Result<[Articles], Error>).self) { group in
                for month in chunk {
                    let monthStr = String(format: "%02d", month)
                    let key = "\(year)-\(monthStr)"
                    if monthlyCache[key] != nil {
                        print("🔥 [HomeViewModel] 이미 캐시됨: \(key)")
                        continue
                    }
                    group.addTask {
                        if Task.isCancelled { return (key, .failure(CancellationError())) }
                        print("🔥 [HomeViewModel] 지정 연도 Task 시작: \(key)")
                        do {
                            let monthly = try await self.useCase.fetchMonthlyData(year: String(year), month: monthStr)
                            print("🔥 [HomeViewModel] 지정 연도 Task 완료: \(key), 아티클 수: \(monthly.count)")
                            return (key, .success(monthly))
                        } catch {
                            print("⚠️ [HomeViewModel] 지정 연도 Task 실패: \(key), error=\(error)")
                            return (key, .failure(error))
                        }
                    }
                }
                for await (key, result) in group {
                    switch result {
                    case .success(let monthly):
                        await MainActor.run {
                            self.monthlyCache[key] = monthly
                            let days = Set(monthly.filter { !$0.receivedArticleList.isEmpty }.map { $0.publishDate })
                            self.dataDaysByMonthCache[key] = days
                            print("🔥 [HomeViewModel] 지정 연도 Task Group 캐시 저장: \(key), days=\(days.sorted())")
                            if isPastYear {
                                let currentKey = "\(formatYear(self.displayedMonth))-\(formatMonth(self.displayedMonth))"
                                if currentKey == key {
                                    self.dataDays = days
                                    self.calendarState.updateDataDays(days)
                                    print("📅 [HomeViewModel] 작년 데이터 즉시 UI 업데이트: \(key), days=\(days.sorted())")
                                }
                            }
                            self.applyDotsIfMatches(key: key, days: days)
                        }
                    case .failure(let error):
                        print("⚠️ [HomeViewModel] 지정 연도 Task Group 캐시 저장 실패: \(key), error=\(error)")
                    }
                }
            }
        }
        warmedYears.insert(year)
        print("✅ [HomeViewModel] 지정 연도 Task Group 워밍업 완료: \(year)")
        
        if isPastYear {
            await MainActor.run { self.checkAndUpdateCurrentMonth() }
        }
    }
    
    // 상세 → 홈 복귀 시 현재 선택 유지
    public func refreshCurrentData() async {
        filterArticles(by: selectedDate)
        print("📅 [HomeViewModel] refreshCurrentData 완료 - selectedDate: \(selectedDate), filteredArticles: \(filteredArticles.count)개")
    }
    
    // Pull to Refresh 시 오늘 날짜로 강제 이동
    public func refreshToToday() async {
        let today = Date()
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let todayDate = calendar.date(from: todayComponents) ?? today
        
        await MainActor.run {
            self.calendarState.selectedDate = todayDate
            self.calendarState.displayedMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: todayDate)
            ) ?? todayDate
            print("📅 [HomeViewModel] Pull to Refresh - 오늘 날짜로 이동: \(todayDate)")
        }
        
        await loadToday()
    }
    
    // 주어진 월에 대해 점 즉시 적용
    public func applyDataDaysForMonth(_ date: Date) {
        let key = "\(formatYear(date))-\(formatMonth(date))"
        if let cachedDays = dataDaysByMonthCache[key] {
            self.dataDays = cachedDays
            self.calendarState.updateDataDays(cachedDays)
            print("📅 [HomeViewModel] 캐시에서 즉시 적용: key=\(key), days=\(cachedDays.sorted())")
            return
        }
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let targetYear = Int(formatYear(date)) ?? currentYear
        print("📅 [HomeViewModel] 연도 확인: 현재=\(currentYear), 대상=\(targetYear)")
        
        if targetYear < currentYear {
            print("📅 [HomeViewModel] 작년 데이터 감지: \(targetYear)년")
            if !warmedYears.contains(targetYear) {
                print("📅 [HomeViewModel] 작년 데이터 미로드, 워밍업 시작: \(targetYear)년")
                Task {
                    await warmupYearCache(year: targetYear, targetMonth: 12)
                    await MainActor.run { self.checkAndUpdateCurrentMonth() }
                }
            } else {
                print("📅 [HomeViewModel] 작년 데이터 이미 로드됨: \(targetYear)년")
            }
        } else {
            print("📅 [HomeViewModel] 올해 또는 미래 데이터: \(targetYear)년")
        }
        
        print("📅 [HomeViewModel] 캐시 없음, 즉시 로드 시작: key=\(key)")
        Task { await loadMonthDataImmediately(for: date) }
        
        self.dataDays = []
        self.calendarState.updateDataDays([])
    }
    
    // 즉시 로드 및 UI 업데이트
    private func loadMonthDataImmediately(for date: Date) async {
        let key = "\(formatYear(date))-\(formatMonth(date))"
        do {
            let monthly = try await useCase.fetchMonthlyData(year: formatYear(date), month: formatMonth(date))
            await MainActor.run {
                self.monthlyCache[key] = monthly
                let days = Set(monthly.filter { !$0.receivedArticleList.isEmpty }.map { $0.publishDate })
                self.dataDaysByMonthCache[key] = days
                
                let currentKey = "\(formatYear(self.displayedMonth))-\(formatMonth(self.displayedMonth))"
                if currentKey == key {
                    self.dataDays = days
                    self.calendarState.updateDataDays(days)
                    print("📅 [HomeViewModel] 즉시 로드 완료 및 UI 업데이트: key=\(key), days=\(days.sorted())")
                } else {
                    print("📅 [HomeViewModel] 즉시 로드 완료 (UI 업데이트 생략): key=\(key), 현재 표시: \(currentKey)")
                }
            }
        } catch {
            print("⚠️ [HomeViewModel] 즉시 로드 실패: key=\(key), error=\(error)")
        }
    }
    
    // 캘린더 버튼: selectedDate 유지, 월 데이터만 로드
    public func loadCalendarData(for date: Date) async {
        let year = formatYear(date)
        let month = formatMonth(date)
        let key = "\(year)-\(month)"
        
        print("📅 [HomeViewModel] 캘린더 데이터 로드: \(year)년 \(month)월, 키: \(key)")
        
        if let existing = loadingTasks[key] { existing.cancel() }
        
        currentMonthKey = key
        latestRequestKey = key
        
        if let cached = monthlyCache[key] {
            let updatedArticles = mergeWithCurrentState(cached)
            self.articlesByMonth = updatedArticles
            self.updateDataDays()
            self.filterArticles(by: selectedDate)
            self.isLoadingMonth = false
            self.calendarState.isLoading = false
            return
        }
        
        let cachedDays = dataDaysByMonthCache[key] ?? []
        self.dataDays = cachedDays
        self.calendarState.updateDataDays(cachedDays)
        
        isLoadingMonth = true
        calendarState.isLoading = true
        
        let task = Task {
            do {
                let monthly = try await useCase.fetchMonthlyData(year: year, month: month)
                if Task.isCancelled || latestRequestKey != key { return }
                await MainActor.run {
                    self.articlesByMonth = monthly
                    self.updateDataDays()
                    self.monthlyCache[key] = monthly
                    self.filterArticles(by: selectedDate)
                    self.isLoadingMonth = false
                    self.calendarState.isLoading = false
                }
            } catch {
                if !Task.isCancelled {
                    await MainActor.run {
                        self.isLoadingMonth = false
                        self.calendarState.isLoading = false
                    }
                }
            }
        }
        loadingTasks[key] = task
        await task.value

        if let y = Int(year) {
            let currentY = Calendar.current.component(.year, from: Date())
            let targetMonth = y < currentY ? 12 : Calendar.current.component(.month, from: Date())
            Task.detached(priority: .background) { [weak self] in
                await self?.warmupYearCache(year: y, targetMonth: targetMonth)
            }
        }
    }
    
    public func loadArticles(for date: Date) async {
        await loadArticles(for: date, forceRefresh: false)
    }
    
    public func loadArticles(for date: Date, forceRefresh: Bool) async {
        let year = formatYear(date)
        let month = formatMonth(date)
        let key = "\(year)-\(month)"
        
        print("📅 [HomeViewModel] 월 데이터 로드 시작: \(year)년 \(month)월, 키: \(key), 강제 새로고침: \(forceRefresh)")
        print("📅 [HomeViewModel] 현재 selectedDate: \(selectedDate)")
        
        if let existingTask = loadingTasks[key] { existingTask.cancel() }
        
        let isMonthChanged = currentMonthKey != key
        currentMonthKey = key
        latestRequestKey = key
        
        print("📅 [HomeViewModel] selectedDate 유지됨: \(selectedDate)")
        
        if !forceRefresh, let cached = monthlyCache[key] {
            print("📅 [HomeViewModel] 캐시된 데이터 사용: \(key), 캐시 크기: \(cached.count)")
            // 캐시된 데이터에도 읽음 상태 복원
            let cachedWithReadStatus = self.applyReadStatusToArticlesByMonth(cached)
            self.articlesByMonth = cachedWithReadStatus
            self.updateDataDays()
            self.filterArticles(by: selectedDate)
            self.isLoadingMonth = false
            self.calendarState.isLoading = false
            return
        }
        
        if isMonthChanged {
            self.dataDays = []
            self.calendarState.updateDataDays([])
        }
        
        isLoadingMonth = true
        calendarState.isLoading = true
        
        let task = Task {
            do {
                print("📅 [HomeViewModel] 새 데이터 요청: \(key)")
                let monthly = try await self.useCase.fetchMonthlyData(year: year, month: month)
                if Task.isCancelled || self.latestRequestKey != key {
                    print("📅 [HomeViewModel] 요청 취소됨 또는 최신이 아님: \(key)")
                    return
                }
                await MainActor.run {
                    print("📅 [HomeViewModel] 새 데이터 로드 완료: \(key), 아티클 수: \(monthly.count)")
                    print("📅 [HomeViewModel] selectedDate 여전히 유지: \(self.selectedDate)")
                    
                    // 읽음 상태 복원
                    let monthlyWithReadStatus = self.applyReadStatusToArticlesByMonth(monthly)
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.articlesByMonth = monthlyWithReadStatus
                        self.monthlyCache[key] = monthlyWithReadStatus
                        self.isLoadingMonth = false
                        self.calendarState.isLoading = false
                    }
                    self.updateDataDays()
                    self.filterArticles(by: self.selectedDate)
                }
            } catch {
                if !Task.isCancelled {
                    print("❌ Monthly fetch failed: \(error)")
                    await MainActor.run {
                        self.isLoadingMonth = false
                        self.calendarState.isLoading = false
                    }
                }
            }
        }
        loadingTasks[key] = task
        await task.value

        if let y = Int(year) {
            let currentY = Calendar.current.component(.year, from: Date())
            let targetMonth = y < currentY ? 12 : Calendar.current.component(.month, from: Date())
            Task.detached(priority: .background) { [weak self] in
                await self?.warmupYearCache(year: y, targetMonth: targetMonth)
            }
        }
    }
 
    // MARK: - 읽음 상태 관리
    private func loadReadArticleIds() {
        if let data = UserDefaults.standard.data(forKey: readArticlesKey),
           let ids = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            readArticleIds = ids
            print("📖 [HomeViewModel] 읽음 상태 로드: \(readArticleIds.count)개")
        }
    }
    
    private func saveReadArticleIds() {
        if let data = try? JSONEncoder().encode(readArticleIds) {
            UserDefaults.standard.set(data, forKey: readArticlesKey)
            print("📖 [HomeViewModel] 읽음 상태 저장: \(readArticleIds.count)개")
        }
    }
    
    private func applyReadStatusToArticles(_ articles: [Article]) -> [Article] {
        return articles.map { article in
            if readArticleIds.contains(article.articleId) {
                return Article(
                    brandName: article.brandName,
                    imageUrl: article.imageUrl,
                    articleTitle: article.articleTitle,
                    articleId: article.articleId,
                    status: "Read"
                )
            }
            return article
        }
    }
    
    private func applyReadStatusToArticlesByMonth(_ articlesByMonth: [Articles]) -> [Articles] {
        return articlesByMonth.map { articles in
            let updatedArticleList = applyReadStatusToArticles(articles.receivedArticleList)
            return Articles(
                publishDate: articles.publishDate,
                receivedUnread: articles.receivedUnread,
                receivedArticleList: updatedArticleList
            )
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
        // 읽음 상태를 영구 저장에 추가
        readArticleIds.insert(articleId)
        saveReadArticleIds()
        
        if let index = filteredArticles.firstIndex(where: { $0.articleId == articleId }) {
            var updatedArticles = filteredArticles
            let article = updatedArticles[index]
            let updatedArticle = Article(
                brandName: article.brandName,
                imageUrl: article.imageUrl,
                articleTitle: article.articleTitle,
                articleId: article.articleId,
                status: "Read"
            )
            updatedArticles[index] = updatedArticle
            self.filteredArticles = updatedArticles
        }
        
        let day = Calendar.current.component(.day, from: selectedDate)
        if let monthIndex = articlesByMonth.firstIndex(where: { $0.publishDate == day }) {
            var updatedMonthArticles = articlesByMonth
            var updatedArticleList = updatedMonthArticles[monthIndex].receivedArticleList
            
            if let articleIndex = updatedArticleList.firstIndex(where: { $0.articleId == articleId }) {
                let article = updatedArticleList[articleIndex]
                let updatedArticle = Article(
                    brandName: article.brandName,
                    imageUrl: article.imageUrl,
                    articleTitle: article.articleTitle,
                    articleId: article.articleId,
                    status: "Read"
                )
                updatedArticleList[articleIndex] = updatedArticle
                updatedMonthArticles[monthIndex] = Articles(
                    publishDate: updatedMonthArticles[monthIndex].publishDate,
                    receivedUnread: updatedMonthArticles[monthIndex].receivedUnread,
                    receivedArticleList: updatedArticleList
                )
                self.articlesByMonth = updatedMonthArticles
            }
        }
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
    
    // MARK: - 점 데이터 조회
    public func getDataDaysForMonth(_ date: Date) -> Set<Int>? {
        let key = "\(formatYear(date))-\(formatMonth(date))"
        if let cachedDays = dataDaysByMonthCache[key] {
            print("📅 [HomeViewModel] 캐시된 점 데이터 반환: \(key), days=\(cachedDays.sorted())")
            return cachedDays
        } else {
            print("📅 [HomeViewModel] 캐시된 점 데이터 없음: \(key)")
            let currentYear = Calendar.current.component(.year, from: Date())
            let targetYear = Int(formatYear(date)) ?? currentYear
            if targetYear < currentYear {
                print("📅 [HomeViewModel] 작년 데이터 감지 (getDataDaysForMonth): \(targetYear)년")
                if !warmedYears.contains(targetYear) {
                    print("📅 [HomeViewModel] 작년 데이터 미로드, 즉시 워밍업 시작: \(targetYear)년")
                    Task {
                        await warmupYearCache(year: targetYear, targetMonth: 12)
                        await MainActor.run { self.checkAndUpdateCurrentMonth() }
                    }
                } else {
                    print("📅 [HomeViewModel] 작년 데이터 이미 로드됨: \(targetYear)년")
                }
            }
            if !dataDays.isEmpty {
                print("📅 [HomeViewModel] 현재 메모리 dataDays 반환: \(dataDays.sorted())")
                return dataDays
            }
            return nil
        }
    }
    
    // 캐시된 데이터와 현재 메모리 최신 상태 병합
    private func mergeWithCurrentState(_ cachedArticles: [Articles]) -> [Articles] {
        if !articlesByMonth.isEmpty {
            print("📅 [HomeViewModel] 현재 메모리 상태 우선 사용")
            return articlesByMonth
        } else {
            print("📅 [HomeViewModel] 캐시된 데이터 사용")
            return cachedArticles
        }
    }
}
