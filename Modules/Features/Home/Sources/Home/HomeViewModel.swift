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
    
   
    
    @Published public var isLoaded: Bool = false
    
    @Published public var filteredArticles: [Article] = []
    @Published public var subscribedNewsletters: [Newsletter] = []
    @Published public var articlesByMonth: [Articles] = []
    @Published public var selectedDate: Date = Date()
    @Published public var monthlyCache: [String: [Articles]] = [:]
    @Published var currentMonthKey: String = ""
    private var latestRequestKey: String = ""
    
    public var dataDays: Set<Int> {
        Set(articlesByMonth.filter { $0.receivedUnread > 0 }.map { $0.publishDate })
    }

    public func updateCalendarData(_ data: [Articles]) {
        self.articlesByMonth = data
    }

    public func selectDate(_ day: Int) {
        if let articles = articlesByMonth.first(where: { $0.publishDate == day })?.receivedArticleList {
            self.filteredArticles = articles
        }
    }
    
    @AppStorage("isGuest") public var isGuest: Bool = false
    
    public init(useCase: FetchHomeDataUseCase) {
        self.useCase = useCase
        setupDataClearing()
    }
    
    private func setupDataClearing() {
        print("🏠 [HomeViewModel] DataClearingService 등록 시작")
        DataClearingService.shared.register { [weak self] in
            print("🏠 [HomeViewModel] 데이터 초기화 실행")
            self?.clearData()
        }
        print("🏠 [HomeViewModel] DataClearingService 등록 완료")
    }
    
    private func clearData() {
        print("🏠 [HomeViewModel] clearData() 실행")
        isLoaded = false
        filteredArticles = []
        subscribedNewsletters = []
        articlesByMonth = []
        selectedDate = Date()
        monthlyCache = [:]
        currentMonthKey = ""
        latestRequestKey = ""
        print("🏠 [HomeViewModel] clearData() 완료")
    }
    
    
    public var articlesByMonthDates: Set<Date> {
        let calendar = Calendar.current
        // selectedDate 의 연·월 컴포넌트만 살리고, publishDate(Int day)만 교체
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        return Set(articlesByMonth.compactMap { articleGroup in
            guard !articleGroup.receivedArticleList.isEmpty else { return nil }
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
            .filter { !$0.receivedArticleList.isEmpty }
            .map { $0.publishDate }
    }
    
    
    public func loadToday() async {
        isLoaded = false
        do {
            let data = try await useCase.fetchTodayData()
            self.filteredArticles = data.articles
            self.subscribedNewsletters = data.activeNewsletters
        } catch {
            print("today fetch error: \(error)")
        }
        isLoaded = true
    }
    
    public func loadArticles(for date: Date) async {
        let year = formatYear(date)
        let month = formatMonth(date)
        let key = "\(year)-\(month)"
        currentMonthKey = key
        latestRequestKey = key
        if let cached = monthlyCache[key] {
            self.articlesByMonth = cached
            self.filterArticles(by: date)
            return
        }
        do {
            let monthly = try await useCase.fetchMonthlyData(year: year, month: month)
            // 최신 요청만 반영
            if latestRequestKey == key {
                self.articlesByMonth = monthly
                self.monthlyCache[key] = monthly
                self.filterArticles(by: date)
                Task { await prefetchAdjacentMonths(for: date) }
            }
        } catch {
            print("❌ Monthly fetch failed: \(error)")
        }
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
