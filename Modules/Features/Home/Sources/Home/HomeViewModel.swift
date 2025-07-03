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
    
    public init(useCase: FetchHomeDataUseCase) {
        self.useCase = useCase
    }
    

    
    @Published public var isLoaded: Bool = false
    
    @Published public var filteredArticles: [Article] = []
    @Published public var subscribedNewsletters: [Newsletter] = []
    @Published public var articlesByMonth: [Articles] = []
    @Published public var selectedDate: Date = Date()
    
    @AppStorage("isGuest") public var isGuest: Bool = false
    
    
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

        if subscribedNewsletters.isEmpty && filteredArticles.isEmpty {
            return .noSubscriptions
        }

        if filteredArticles.isEmpty {
            return .noArticles
        }

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
        
        do {
            let monthly = try await useCase.fetchMonthlyData(year: year, month: month)
            self.articlesByMonth = monthly
            self.filterArticles(by: date)
        } catch {
            print("❌ Monthly fetch failed: \(error)")
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
