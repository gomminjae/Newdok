//
//  HomeViewModel.swift
//  Home
//
//  Created by 권민재 on 4/16/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
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
    
    // 캘린더 상태를 별도 객체로 분리
    @Published public var calendarState: CalendarState
    
    public init(useCase: FetchHomeDataUseCase) {
        self.useCase = useCase
        self.calendarState = CalendarState()
        self.dataDays = []
        
        // 초기화 시 별도 로딩 제거 - onAppear에서 loadToday()로 통합
    }
    
    @Published public var isLoaded: Bool = false
    @Published public var filteredArticles: [Article] = []
    @Published public var subscribedNewsletters: [Newsletter] = []
    @Published public var articlesByMonth: [Articles] = []
    @Published public var monthlyCache: [String: [Articles]] = [:]
    // 월별 점(날짜) 캐시: "yyyy-MM" → Set<Int>
    @Published private var dataDaysByMonthCache: [String: Set<Int>] = [:]
    // 연간 캐시 워밍업 중복 실행 방지
    private var isWarmingCache: Bool = false
    // 이미 워밍업한 연도 집합
    private var warmedYears: Set<Int> = []
    @Published var currentMonthKey: String = ""
    @Published public var dataDays: Set<Int> = []
    @Published public var onMonthChanged: ((Date) -> Void)?
    @Published public var isLoadingMonth: Bool = false
    private var latestRequestKey: String = ""
    private var loadingTasks: [String: Task<Void, Never>] = [:]
    
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
        // 읽음 여부와 무관하게, 해당 날짜에 아티클 리스트가 존재하면 점 표시
        let daysWithArticles = articlesByMonth.filter { !$0.receivedArticleList.isEmpty }
        let newDataDays = Set(daysWithArticles.map { $0.publishDate })
        
       
        
        // 디버깅: 모든 날짜의 상태 출력
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
        // 월 키 기준 캐시에도 저장
        if !currentMonthKey.isEmpty {
            dataDaysByMonthCache[currentMonthKey] = newDataDays
        }
        print("📅 [HomeViewModel] dataDays UI 업데이트 완료: \(self.dataDays.sorted())")
    }

    public func selectDate(_ day: Int) {
        if let articles = articlesByMonth.first(where: { $0.publishDate == day })?.receivedArticleList {
            self.filteredArticles = articles
        }
    }
    
    // 새로운 메서드: 날짜 선택 시 올바른 월 보장
    public func selectDateWithMonthGuarantee(_ date: Date) {
        let calendar = Calendar.current
        let selectedDay = calendar.component(.day, from: date)
        
        print("📅 [HomeViewModel] 날짜 선택: \(date)")
        
        // 선택된 날짜만 업데이트 (월은 변경하지 않음)
        calendarState.selectedDate = date
        
        // 해당 날짜의 아티클 로드
        Task {
            await loadArticles(for: date)
            self.selectDate(selectedDay)
        }
    }
    
    @AppStorage("isGuest") public var isGuest: Bool = false
    
    public var articlesByMonthDates: Set<Date> {
        let calendar = Calendar.current
        // selectedDate 의 연·월 컴포넌트만 살리고, publishDate(Int day)만 교체
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        return Set(articlesByMonth.compactMap { articleGroup in
            guard articleGroup.receivedUnread > 0 else { return nil }
            var dc = comps
            dc.day = articleGroup.publishDate
            return calendar.date(from: dc)
        })
    }
    
    var homeState: HomeState {
        if isGuest {
            return .guest
        }

        if !isLoaded {
            return .none
        }

        // 둘 다 없음 - 구독 안내
        if subscribedNewsletters.isEmpty && filteredArticles.isEmpty {
            return .noSubscriptions
        }

        // 구독은 없지만 아티클은 있음 (구독 확인 메일 온 경우) - 구독 안내
        if subscribedNewsletters.isEmpty && !filteredArticles.isEmpty {
            return .noSubscriptions
        }

        // 구독은 있지만 아티클이 없음 - 아티클 안내
        if filteredArticles.isEmpty {
            return .noArticles
        }

        // 둘 다 있음 - 아티클 표시
        return .articles
    }
    
    public var activeArticeDays: [Int] {
        articlesByMonth
            .filter { $0.receivedUnread > 0 }
            .map { $0.publishDate }
    }
    
    // MARK: - Data Loading Methods
    public func loadToday() async {
        // 배치 업데이트를 위한 임시 변수
        var tempArticles: [Article] = []
        var tempNewsletters: [Newsletter] = []
        
        do {
            // 1단계: 먼저 오늘 데이터 로드 (구독 상태 확인)
            let data = try await useCase.fetchTodayData()
            tempArticles = data.articles
            tempNewsletters = data.activeNewsletters
            
            // 2단계: 오늘 날짜로 리셋하고 캘린더 데이터 로드
            let today = Date()
            calendarState.selectedDate = today
            calendarState.displayedMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: today)) ?? today
            
            await loadArticles(for: today)
            
            // 배치 업데이트로 UI 렉 최소화
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.filteredArticles = tempArticles
                    self.subscribedNewsletters = tempNewsletters
                    self.isLoaded = true
                }
            }
            // 3단계: 올해 월간 데이터 백그라운드 캐싱(1월~현재월)
            Task.detached(priority: .background) { [weak self] in
                // 초기 화면 안정화 시간을 조금 부여
                try? await Task.sleep(nanoseconds: 300_000_000)
                await self?.warmupYearCache(for: today)
            }
        } catch {
            print("today fetch error: \(error)")
            await MainActor.run {
                self.isLoaded = true
            }
        }
    }
    
    // Swift 6 Task Group을 활용한 동시성 워밍업
    private func warmupYearCache(for date: Date) async {
        // 중복 실행 방지
        if isWarmingCache { return }
        isWarmingCache = true
        defer { isWarmingCache = false }

        let cal = Calendar.current
        let year = Int(formatYear(date)) ?? cal.component(.year, from: date)
        let currentMonth = cal.component(.month, from: date)
        warmedYears.insert(year)
        print("🔥 [HomeViewModel] Task Group 워밍업 시작: \(year)년 1..\(currentMonth)월")
        
        // Swift 6: Task Group을 활용한 동시 실행
        await withTaskGroup(of: (String, Result<[Articles], Error>).self) { group in
            for month in 1...currentMonth {
                let monthStr = String(format: "%02d", month)
                let key = "\(year)-\(monthStr)"
                
                // 이미 캐시되어 있으면 스킵
                if monthlyCache[key] != nil { 
                    print("🔥 [HomeViewModel] 이미 캐시됨: \(key)")
                    continue 
                }
                
                group.addTask {
                    print("🔥 [HomeViewModel] Task 시작: \(key)")
                    do {
                        let monthly = try await self.useCase.fetchMonthlyData(year: String(year), month: monthStr)
                        print("🔥 [HomeViewModel] Task 완료: \(key), 아티클 수: \(monthly.count)")
                        return (key, Result.success(monthly))
                    } catch {
                        print("⚠️ [HomeViewModel] Task 실패: \(key), error=\(error)")
                        return (key, Result.failure(error))
                    }
                }
            }
            
            // 결과 수집 및 캐시 저장
            for await (key, result) in group {
                switch result {
                case .success(let monthly):
                    await MainActor.run {
                        self.monthlyCache[key] = monthly
                        let days = Set(monthly.filter { !$0.receivedArticleList.isEmpty }.map { $0.publishDate })
                        self.dataDaysByMonthCache[key] = days
                        print("🔥 [HomeViewModel] Task Group 캐시 저장: \(key), days=\(days.sorted())")
                    }
                case .failure(let error):
                    print("⚠️ [HomeViewModel] Task Group 캐시 저장 실패: \(key), error=\(error)")
                }
            }
        }
        
        print("✅ [HomeViewModel] Task Group 워밍업 완료")
    }

    // Swift 6 Task Group을 활용한 지정 연도 동시성 워밍업
    private func warmupYearCache(year: Int, targetMonth: Int) async {
        if warmedYears.contains(year) { return }
        let cal = Calendar.current
        let months = max(1, min(12, targetMonth))
        print("🔥 [HomeViewModel] 지정 연도 Task Group 워밍업 시작: \(year)년 1..\(months)월")
        
        // Swift 6: Task Group을 활용한 동시 실행
        await withTaskGroup(of: (String, Result<[Articles], Error>).self) { group in
            for month in 1...months {
                let monthStr = String(format: "%02d", month)
                let key = "\(year)-\(monthStr)"
                
                // 이미 캐시되어 있으면 스킵
                if monthlyCache[key] != nil { 
                    print("🔥 [HomeViewModel] 이미 캐시됨: \(key)")
                    continue 
                }
                
                group.addTask {
                    print("🔥 [HomeViewModel] 지정 연도 Task 시작: \(key)")
                    do {
                        let monthly = try await self.useCase.fetchMonthlyData(year: String(year), month: monthStr)
                        print("🔥 [HomeViewModel] 지정 연도 Task 완료: \(key), 아티클 수: \(monthly.count)")
                        return (key, Result.success(monthly))
                    } catch {
                        print("⚠️ [HomeViewModel] 지정 연도 Task 실패: \(key), error=\(error)")
                        return (key, Result.failure(error))
                    }
                }
            }
            
            // 결과 수집 및 캐시 저장
            for await (key, result) in group {
                switch result {
                case .success(let monthly):
                    await MainActor.run {
                        self.monthlyCache[key] = monthly
                        let days = Set(monthly.filter { !$0.receivedArticleList.isEmpty }.map { $0.publishDate })
                        self.dataDaysByMonthCache[key] = days
                        print("🔥 [HomeViewModel] 지정 연도 Task Group 캐시 저장: \(key), days=\(days.sorted())")
                    }
                case .failure(let error):
                    print("⚠️ [HomeViewModel] 지정 연도 Task Group 캐시 저장 실패: \(key), error=\(error)")
                }
            }
        }
        
        warmedYears.insert(year)
        print("✅ [HomeViewModel] 지정 연도 Task Group 워밍업 완료: \(year)")
    }
    
    // 아티클 상세에서 돌아올 때 사용할 메서드 - 현재 선택된 날짜 유지
    public func refreshCurrentData() async {
        // 현재 선택된 날짜만 다시 필터링 (캐시된 데이터 사용)
        filterArticles(by: selectedDate)
        print("📅 [HomeViewModel] refreshCurrentData 완료 - selectedDate: \(selectedDate), filteredArticles: \(filteredArticles.count)개")
    }
    
    // 주어진 월에 대해 캐싱된 점 세트를 즉시 적용
    public func applyDataDaysForMonth(_ date: Date) {
        let key = "\(formatYear(date))-\(formatMonth(date))"
        let set = dataDaysByMonthCache[key] ?? []
        self.dataDays = set
        self.calendarState.updateDataDays(set)
        print("📅 [HomeViewModel] applyDataDaysForMonth: key=\(key), days=\(set.sorted())")
    }
    
    // 캘린더 버튼용: selectedDate는 변경하지 않고 해당 월 데이터만 로드
    public func loadCalendarData(for date: Date) async {
        let year = formatYear(date)
        let month = formatMonth(date)
        let key = "\(year)-\(month)"
        
        print("📅 [HomeViewModel] 캘린더 데이터 로드: \(year)년 \(month)월, 키: \(key)")
        
        // 진행 중 태스크가 있으면 취소
        if let existing = loadingTasks[key] { existing.cancel() }
        
        currentMonthKey = key
        latestRequestKey = key
        
        // 캐시 우선 (초기화 없이 즉시 반영)
        if let cached = monthlyCache[key] {
            // 캐시된 데이터를 사용하되, 현재 메모리의 최신 상태와 병합
            let updatedArticles = mergeWithCurrentState(cached)
            self.articlesByMonth = updatedArticles
            self.updateDataDays()
            self.filterArticles(by: selectedDate)
            self.isLoadingMonth = false
            self.calendarState.isLoading = false
            return
        }
        
        // 캐시가 없을 때만 초기화하여 잔상 제거
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

        // 다른 연도로 이동한 경우, 해당 연도를 백그라운드로 프리워밍
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
        
        // 이미 로딩 중인 요청이 있으면 취소
        if let existingTask = loadingTasks[key] {
            existingTask.cancel()
        }
        
        // 월이 변경되었는지 확인
        let isMonthChanged = currentMonthKey != key
        currentMonthKey = key
        latestRequestKey = key
        
        print("📅 [HomeViewModel] selectedDate 유지됨: \(selectedDate)")
        
        // 캐시 우선: 강제 새로고침이 아니고, 캐시가 있으면 즉시 반영 (초기화 없음)
        if !forceRefresh, let cached = monthlyCache[key] {
            print("📅 [HomeViewModel] 캐시된 데이터 사용: \(key), 캐시 크기: \(cached.count)")
            self.articlesByMonth = cached
            self.updateDataDays()
            self.filterArticles(by: selectedDate)
            self.isLoadingMonth = false
            self.calendarState.isLoading = false
            return
        }
        
        // 여기까지 캐시가 없으면, 월 전환 시 점 잔상 제거를 위해 즉시 초기화
        if isMonthChanged {
            self.dataDays = []
            self.calendarState.updateDataDays([])
        }
        
        // 로딩 상태 시작
        isLoadingMonth = true
        calendarState.isLoading = true
        
        // 새로운 로딩 태스크 생성
        let task = Task {
            do {
                print("📅 [HomeViewModel] 새 데이터 요청: \(key)")
                let monthly = try await useCase.fetchMonthlyData(year: year, month: month)
                
                // 태스크가 취소되었거나 최신 요청이 아니면 무시
                if Task.isCancelled || latestRequestKey != key {
                    print("📅 [HomeViewModel] 요청 취소됨 또는 최신이 아님: \(key)")
                    return
                }
                
                await MainActor.run {
                    print("📅 [HomeViewModel] 새 데이터 로드 완료: \(key), 아티클 수: \(monthly.count)")
                    print("📅 [HomeViewModel] selectedDate 여전히 유지: \(selectedDate)")
                    
                    // 배치 업데이트로 UI 렉 최소화
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.articlesByMonth = monthly
                        self.monthlyCache[key] = monthly
                        self.isLoadingMonth = false
                        self.calendarState.isLoading = false
                    }
                    
                    // 데이터 업데이트 후 필터링
                    self.updateDataDays()
                    self.filterArticles(by: selectedDate)
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

        // 다른 연도로 이동한 경우, 해당 연도를 백그라운드로 프리워밍
        if let y = Int(year) {
            let currentY = Calendar.current.component(.year, from: Date())
            let targetMonth = y < currentY ? 12 : Calendar.current.component(.month, from: Date())
            Task.detached(priority: .background) { [weak self] in
                await self?.warmupYearCache(year: y, targetMonth: targetMonth)
            }
        }
    }
 
    // prefetchAdjacentMonths 기능 제거

    public func filterArticles(by date: Date) {
        let day = Calendar.current.component(.day, from: date)
        self.filteredArticles = articlesByMonth
            .first(where: { $0.publishDate == day })?
            .receivedArticleList ?? []
    }
    
    public func markArticleAsRead(articleId: Int) {
        // filteredArticles에서 즉시 업데이트
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
        
        // articlesByMonth에서도 업데이트
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
        formatter.dateFormat = "M월 d일(E)" // ex: 2월 23일(일)
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
    
    // 캘린더에서 사용할 캐시된 점 데이터 조회
    public func getDataDaysForMonth(_ date: Date) -> Set<Int>? {
        let key = "\(formatYear(date))-\(formatMonth(date))"
        // 캐시된 데이터가 있으면 반환, 없으면 nil
        if let cachedDays = dataDaysByMonthCache[key] {
            print("📅 [HomeViewModel] 캐시된 점 데이터 반환: \(key), days=\(cachedDays.sorted())")
            return cachedDays
        } else {
            print("📅 [HomeViewModel] 캐시된 점 데이터 없음: \(key)")
            // 실기기에서 캐시가 없으면 현재 메모리의 dataDays 반환 (임시 해결)
            if !dataDays.isEmpty {
                print("📅 [HomeViewModel] 현재 메모리 dataDays 반환: \(dataDays.sorted())")
                return dataDays
            }
            return nil
        }
    }
    
    // 캐시된 데이터와 현재 메모리의 최신 상태를 병합
    private func mergeWithCurrentState(_ cachedArticles: [Articles]) -> [Articles] {
        // 현재 메모리에 있는 최신 상태를 우선 사용
        // 캐시된 데이터는 백업으로만 사용
        if !articlesByMonth.isEmpty {
            print("📅 [HomeViewModel] 현재 메모리 상태 우선 사용")
            return articlesByMonth
        } else {
            print("📅 [HomeViewModel] 캐시된 데이터 사용")
            return cachedArticles
        }
    }
    
}
