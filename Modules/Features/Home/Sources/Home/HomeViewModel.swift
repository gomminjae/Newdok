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
        // 초기화 시 selectedDate와 displayedMonth를 동기화
        displayedMonth = selectedDate
    }
    
    public func updateSelectedDate(_ date: Date) {
        selectedDate = date
        // displayedMonth 자동 동기화 제거 - 캘린더에서 월 변경이 제대로 작동하도록
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
        
        // 초기화 시 현재 월의 데이터를 미리 로드
        Task {
            await loadArticles(for: calendarState.selectedDate)
        }
    }
    
    @Published public var isLoaded: Bool = false
    @Published public var filteredArticles: [Article] = []
    @Published public var subscribedNewsletters: [Newsletter] = []
    @Published public var articlesByMonth: [Articles] = []
    @Published public var monthlyCache: [String: [Articles]] = [:]
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
        let daysWithArticles = articlesByMonth.filter { $0.receivedUnread > 0 }
        let newDataDays = Set(daysWithArticles.map { $0.publishDate })
        
        print("📅 [HomeViewModel] dataDays 업데이트:")
        print("  - 총 날짜 수: \(articlesByMonth.count)")
        print("  - 아티클 있는 날짜 수: \(daysWithArticles.count)")
        print("  - 아티클 있는 날짜: \(daysWithArticles.map { "\($0.publishDate)일(\($0.receivedUnread)개)" }.sorted())")
        print("  - 이전 dataDays: \(dataDays.sorted())")
        print("  - 새로운 dataDays: \(newDataDays.sorted())")
        
        // 디버깅: 모든 날짜의 상태 출력
        for article in articlesByMonth.sorted(by: { $0.publishDate < $1.publishDate }) {
            if article.receivedUnread > 0 {
                print("  ✅ \(article.publishDate)일: \(article.receivedUnread)개 아티클")
            } else {
                print("  ❌ \(article.publishDate)일: 아티클 없음")
            }
        }
        
        // 캘린더 상태와 동기화
        self.dataDays = newDataDays
        self.calendarState.updateDataDays(newDataDays)
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
        
        // 즉시 calendarState 업데이트 (UI 반영)
        calendarState.selectedDate = date
        calendarState.displayedMonth = date
        
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
        isLoaded = false
        do {
            let data = try await useCase.fetchTodayData()
            self.filteredArticles = data.articles
            self.subscribedNewsletters = data.activeNewsletters
            // 오늘 데이터 로드 후 현재 월의 캘린더 데이터도 로드
            await loadArticles(for: selectedDate)
        } catch {
            print("today fetch error: \(error)")
        }
        isLoaded = true
    }
    
    public func loadArticles(for date: Date) async {
        let year = formatYear(date)
        let month = formatMonth(date)
        let key = "\(year)-\(month)"
        
        print("📅 [HomeViewModel] 월 데이터 로드 시작: \(year)년 \(month)월, 키: \(key)")
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
        
        // 캐시된 데이터가 있으면 즉시 사용
        if let cached = monthlyCache[key] {
            print("📅 [HomeViewModel] 캐시된 데이터 사용: \(key), 캐시 크기: \(cached.count)")
            self.articlesByMonth = cached
            self.updateDataDays()
            self.filterArticles(by: selectedDate)
            // 캐시된 데이터 사용 시에도 로딩 상태 false로 설정
            self.isLoadingMonth = false
            self.calendarState.isLoading = false
            return
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
                    self.articlesByMonth = monthly
                    self.updateDataDays()
                    self.monthlyCache[key] = monthly
                    self.filterArticles(by: selectedDate)
                    self.isLoadingMonth = false
                    self.calendarState.isLoading = false
                }
                
                // 인접 월 프리페치
                await prefetchAdjacentMonths(for: date)
                
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
    }
    
    // 캘린더 버튼을 위한 별도 메서드 - selectedDate 변경 없이 데이터만 로드
    public func loadCalendarData(for date: Date) async {
        let year = formatYear(date)
        let month = formatMonth(date)
        let key = "\(year)-\(month)"
        
        print("📅 [HomeViewModel] 캘린더 데이터 로드: \(year)년 \(month)월, 키: \(key)")
        
        // 이미 로딩 중인 요청이 있으면 취소
        if let existingTask = loadingTasks[key] {
            existingTask.cancel()
        }
        
        currentMonthKey = key
        latestRequestKey = key
        
        // 캐시된 데이터가 있으면 즉시 사용
        if let cached = monthlyCache[key] {
            print("📅 [HomeViewModel] 캐시된 데이터 사용: \(key), 캐시 크기: \(cached.count)")
            self.articlesByMonth = cached
            self.updateDataDays()
            self.filterArticles(by: selectedDate)
            // 캐시된 데이터 사용 시에도 로딩 상태 false로 설정
            self.isLoadingMonth = false
            self.calendarState.isLoading = false
            return
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
                    self.articlesByMonth = monthly
                    self.updateDataDays()
                    self.monthlyCache[key] = monthly
                    self.filterArticles(by: selectedDate)
                    self.isLoadingMonth = false
                    self.calendarState.isLoading = false
                }
                
                // 인접 월 프리페치
                await prefetchAdjacentMonths(for: date)
                
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
    }

    private func prefetchAdjacentMonths(for date: Date) async {
        let calendar = Calendar.current
        if let prev = calendar.date(byAdding: .month, value: -1, to: date) {
            let key = "\(formatYear(prev))-\(formatMonth(prev))"
            if monthlyCache[key] == nil {
                if let monthly = try? await useCase.fetchMonthlyData(year: formatYear(prev), month: formatMonth(prev)) {
                    monthlyCache[key] = monthly
                }
            }
        }
        if let next = calendar.date(byAdding: .month, value: 1, to: date) {
            let key = "\(formatYear(next))-\(formatMonth(next))"
            if monthlyCache[key] == nil {
                if let monthly = try? await useCase.fetchMonthlyData(year: formatYear(next), month: formatMonth(next)) {
                    monthlyCache[key] = monthly
                }
            }
        }
    }
    
    public func filterArticles(by date: Date) {
        let day = Calendar.current.component(.day, from: date)
        self.filteredArticles = articlesByMonth
            .first(where: { $0.publishDate == day })?
            .receivedArticleList ?? []
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
}
