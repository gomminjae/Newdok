//
//  HomeViewModelResult.swift
//  Home
//
//  Created by AI Assistant on 1/14/25.
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
public final class HomeViewModelResult: ObservableObject {
    
    // MARK: - Dependencies
    private let useCase: FetchHomeDataUseCaseResult
    
    // MARK: - Published Properties
    @Published public var isLoaded: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    @Published public var filteredArticles: [Article] = []
    @Published public var subscribedNewsletters: [Newsletter] = []
    @Published public var articlesByMonth: [Articles] = []
    @Published public var selectedDate: Date = Date()
    @Published public var monthlyCache: [String: [Articles]] = [:]
    @Published var currentMonthKey: String = ""
    private var latestRequestKey: String = ""
    
    @AppStorage("isGuest") public var isGuest: Bool = false
    
    // MARK: - Initialization
    public init(useCase: FetchHomeDataUseCaseResult) {
        self.useCase = useCase
    }
    
    // MARK: - Computed Properties
    public var dataDays: Set<Int> {
        Set(articlesByMonth.filter { $0.receivedUnread > 0 }.map { $0.publishDate })
    }
    
    public var articlesByMonthDates: Set<Date> {
        let calendar = Calendar.current
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
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일(E)"
        return formatter.string(from: selectedDate)
    }
    
    // MARK: - Public Methods
    public func updateCalendarData(_ data: [Articles]) {
        self.articlesByMonth = data
    }

    public func selectDate(_ day: Int) {
        if let articles = articlesByMonth.first(where: { $0.publishDate == day })?.receivedArticleList {
            self.filteredArticles = articles
        }
    }
    
    public func loadToday() async {
        await MainActor.run {
            isLoaded = false
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.fetchTodayData()
        
        await result
            .onSuccess { [weak self] homeData in
                await self?.handleTodayDataSuccess(homeData)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "오늘의 데이터")
            }
        
        await MainActor.run {
            isLoaded = true
            isLoading = false
        }
    }
    
    public func loadArticles(for date: Date) async {
        let year = formatYear(date)
        let month = formatMonth(date)
        let key = "\(year)-\(month)"
        currentMonthKey = key
        latestRequestKey = key
        
        // 캐시 확인
        if let cached = monthlyCache[key] {
            self.articlesByMonth = cached
            self.filterArticles(by: date)
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.fetchMonthlyData(year: year, month: month)
        
        await result
            .onSuccess { [weak self] monthlyData in
                await self?.handleMonthlyDataSuccess(monthlyData, key: key, date: date)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "월별 데이터")
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func filterArticles(by date: Date) {
        let day = Calendar.current.component(.day, from: date)
        self.filteredArticles = articlesByMonth
            .first(where: { $0.publishDate == day })?
            .receivedArticleList ?? []
    }
    
    // MARK: - Private Methods
    @MainActor
    private func handleTodayDataSuccess(_ homeData: HomeData) async {
        self.filteredArticles = homeData.articles
        self.subscribedNewsletters = homeData.activeNewsletters
    }
    
    @MainActor
    private func handleMonthlyDataSuccess(_ monthlyData: [Articles], key: String, date: Date) async {
        // 최신 요청만 반영
        guard latestRequestKey == key else { return }
        
        self.articlesByMonth = monthlyData
        self.monthlyCache[key] = monthlyData
        self.filterArticles(by: date)
        
        // 인접 월 미리 가져오기
        Task { await prefetchAdjacentMonths(for: date) }
    }
    
    @MainActor
    private func handleError(_ error: AppError, context: String) async {
        switch error {
        case .network(let networkError):
            switch networkError {
            case .networkUnavailable:
                self.errorMessage = "네트워크 연결을 확인해주세요"
            case .timeout:
                self.errorMessage = "요청 시간이 초과되었습니다"
            case .serverError(let statusCode, let message):
                self.errorMessage = "서버 오류가 발생했습니다 (\(statusCode))"
            case .unknown(let message):
                self.errorMessage = message
            }
        case .validation(let validationError):
            switch validationError {
            case .invalidFormat(let field):
                self.errorMessage = "\(field) 형식이 올바르지 않습니다"
            default:
                self.errorMessage = "입력값이 올바르지 않습니다"
            }
        case .business(let businessError):
            switch businessError {
            case .dataNotFound:
                self.errorMessage = "\(context)가 없습니다"
            case .operationNotAllowed:
                self.errorMessage = "권한이 없습니다"
            default:
                self.errorMessage = "데이터를 불러올 수 없습니다"
            }
        case .unknown(let message):
            self.errorMessage = message.isEmpty ? "\(context) 로딩 중 오류가 발생했습니다" : message
        }
        
        print("❌ \(context) 실패: \(error)")
    }
    
    private func prefetchAdjacentMonths(for date: Date) async {
        let calendar = Calendar.current
        
        // 이전 달
        if let prev = calendar.date(byAdding: .month, value: -1, to: date) {
            let key = "\(formatYear(prev))-\(formatMonth(prev))"
            if monthlyCache[key] == nil {
                let result = await useCase.fetchMonthlyData(year: formatYear(prev), month: formatMonth(prev))
                if case .success(let monthly) = result {
                    await MainActor.run {
                        monthlyCache[key] = monthly
                    }
                }
            }
        }
        
        // 다음 달
        if let next = calendar.date(byAdding: .month, value: 1, to: date) {
            let key = "\(formatYear(next))-\(formatMonth(next))"
            if monthlyCache[key] == nil {
                let result = await useCase.fetchMonthlyData(year: formatYear(next), month: formatMonth(next))
                if case .success(let monthly) = result {
                    await MainActor.run {
                        monthlyCache[key] = monthly
                    }
                }
            }
        }
    }
    
    // MARK: - Date Formatters
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