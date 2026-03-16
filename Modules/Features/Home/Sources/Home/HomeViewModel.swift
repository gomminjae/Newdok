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
        $displayedMonth
            .removeDuplicates { Calendar.current.isDate($0, equalTo: $1, toGranularity: .month) }
            .dropFirst()
            .handleEvents(receiveOutput: { [weak viewModel] newMonth in
                viewModel?.applyDataDaysForMonth(newMonth)
            })
            .map { [weak viewModel] newMonth -> AnyPublisher<Void, Never> in
                guard let vm = viewModel else {
                    return Empty<Void, Never>().eraseToAnyPublisher()
                }
                return Deferred {
                    Future<Void, Never> { promise in
                        Task { @MainActor [weak vm] in
                            guard let vm else {
                                promise(.success(()))
                                return
                            }
                            await vm.loadMonthData(for: newMonth)
                            promise(.success(()))
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink { _ in }
            .store(in: &cancellables)
    }
}

public enum HomeState {
    case idle
    case loading
    case guest
    case noSubscriptions
    case noArticles
    case articles
}

@MainActor
public final class HomeViewModel: ObservableObject {
    private let useCase: HomeBusinessUseCase
    @Published public var calendarState: CalendarState
    private var cancellables = Set<AnyCancellable>()
    
    @Published public var homeState: HomeState = .idle
    @Published public var filteredArticles: [Article] = []
    @Published public var subscribedNewsletters: [Newsletter] = []
    @Published public var articlesByMonth: [Articles] = []
    
    private var dataDaysCache: [String: Set<Int>] = [:]
    private var latestMonthRequestKey: String?
    
    @AppStorage("isGuest") public var isGuest: Bool = false
    
    public init(useCase: HomeBusinessUseCase) {
        self.useCase = useCase
        self.calendarState = CalendarState()
        
        calendarState.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
        
        calendarState.bind(to: self)
        
        Task { [weak self] in
            guard let self else { return }
            let snapshot = await useCase.snapshot()
            await MainActor.run {
                // 이미 loading/loaded 상태면 stale snapshot으로 덮어쓰지 않음
                guard self.homeState == .idle else { return }
                self.applySnapshot(snapshot)
            }
        }
    }
    
    // MARK: - Computed Properties
    public var selectedDate: Date {
        get { calendarState.selectedDate }
        set { calendarState.selectedDate = newValue }
    }
    
    public var displayedMonth: Date {
        get { calendarState.displayedMonth }
        set { calendarState.displayedMonth = newValue }
    }
    
    public var articlesByMonthDates: Set<Date> {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: selectedDate)
        return Set(articlesByMonth.compactMap { group in
            guard group.unreadCount > 0 else { return nil }
            var dc = comps
            dc.day = group.publishDate
            return calendar.date(from: dc)
        })
    }
    
    private func resolveState() -> HomeState {
        if isGuest { return .guest }
        if subscribedNewsletters.isEmpty && filteredArticles.isEmpty { return .noSubscriptions }
        if filteredArticles.isEmpty { return .noArticles }
        return .articles
    }
    
    public var activeArticeDays: [Int] {
        articlesByMonth
            .filter { $0.unreadCount > 0 }
            .map { $0.publishDate }
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일(E)"
        return formatter.string(from: selectedDate)
    }
    
    // MARK: - Intent Handlers
    public func loadToday() async {
        if homeState == .idle { homeState = .loading }
        let snapshot = await useCase.loadToday()
        applySnapshot(snapshot)
    }
    
    public func loadMonthDataIfNeeded(for date: Date) async {
        await performMonthRequest(for: date) {
            await self.useCase.loadMonthDataIfNeeded(for: date)
        }
    }
    
    public func loadMonthData(for date: Date, forceReload: Bool = false) async {
        await performMonthRequest(for: date) {
            await self.useCase.loadMonthData(for: date, forceReload: forceReload)
        }
    }
    
    public func selectDateWithMonthGuarantee(_ date: Date) {
        calendarState.selectedDate = date
        Task { [weak self] in
            guard let self else { return }
            let snapshot = await useCase.selectDateWithMonthGuarantee(date)
            await MainActor.run { self.applySnapshot(snapshot) }
        }
    }
    
    public func refreshCurrentData() async {
        let snapshot = await useCase.refreshCurrentData()
        applySnapshot(snapshot)
    }
    
    public func refreshToToday() async {
        let snapshot = await useCase.refreshToToday()
        applySnapshot(snapshot)
    }
    
    public func applyDataDaysForMonth(_ date: Date) {
        let key = monthKey(for: date)
        if let cached = dataDaysCache[key] {
            calendarState.dataDays = cached
        } else {
            calendarState.dataDays = []
            Task { [weak self] in
                guard let self else { return }
                let cached = await self.useCase.cachedDataDays(for: date)
                await MainActor.run {
                    if !cached.isEmpty {
                        self.storeDataDays(cached, for: date)
                        if Calendar.current.isDate(date, equalTo: self.calendarState.displayedMonth, toGranularity: .month) {
                            self.calendarState.dataDays = cached
                        }
                    }
                }
                if cached.isEmpty {
                    self.fetchDataDays(for: date)
                }
            }
        }
    }
    
    public func markArticleAsRead(articleId: Int) async {
        let snapshot = await useCase.markArticleAsRead(articleId: articleId)
        applySnapshot(snapshot)
    }
    
    public func resetForAuthChange() async {
        homeState = .loading
        dataDaysCache.removeAll()
        let snapshot = await useCase.resetForAuthChange()
        applySnapshot(snapshot)
    }
    
    public func shouldReloadToday(currentDate: Date = Date()) async -> Bool {
        await useCase.shouldReloadToday(currentDate: currentDate)
    }
    
    // MARK: - Snapshot Application
    private func applySnapshot(_ snapshot: HomeSnapshot) {
        calendarState.selectedDate = snapshot.selectedDate
        calendarState.displayedMonth = snapshot.displayedMonth
        calendarState.dataDays = snapshot.dataDays
        storeDataDays(snapshot.dataDays, for: snapshot.displayedMonth)
        calendarState.isLoading = snapshot.isCalendarLoading
        withAnimation(.easeInOut(duration: 0.25)) {
            filteredArticles = snapshot.filteredArticles
            subscribedNewsletters = snapshot.subscribedNewsletters
            articlesByMonth = snapshot.articlesByMonth
            if snapshot.isLoaded {
                homeState = resolveState()
            }
        }
    }
    
    private func storeDataDays(_ days: Set<Int>, for date: Date) {
        dataDaysCache[monthKey(for: date)] = days
    }
    
    private func fetchDataDays(for date: Date) {
        Task { [weak self] in
            guard let self else { return }
            let days = await self.useCase.fetchDataDays(for: date)
            await MainActor.run {
                self.storeDataDays(days, for: date)
                if Calendar.current.isDate(date, equalTo: self.calendarState.displayedMonth, toGranularity: .month) {
                    self.calendarState.dataDays = days
                }
            }
        }
    }
    
    public func calendarDataDays(for date: Date) async -> Set<Int> {
        let key = monthKey(for: date)
        if let cached = dataDaysCache[key] {
            return cached
        }
        
        let cached = await useCase.cachedDataDays(for: date)
        if !cached.isEmpty {
            await MainActor.run { self.storeDataDays(cached, for: date) }
            return cached
        }
        
        let fetched = await useCase.fetchDataDays(for: date)
        await MainActor.run { self.storeDataDays(fetched, for: date) }
        return fetched
    }
    
    private func monthKey(for date: Date) -> String {
        monthKeyFormatter.string(from: date)
    }
    
    private func performMonthRequest(for date: Date, loader: @escaping () async -> HomeSnapshot) async {
        let requestKey = monthKey(for: date)
        latestMonthRequestKey = requestKey
        calendarState.isLoading = true
        let snapshot = await loader()
        storeDataDays(snapshot.dataDays, for: snapshot.displayedMonth)
        prefetchAdjacentDataDays(from: snapshot.displayedMonth)
        guard latestMonthRequestKey == requestKey else { return }
        applySnapshot(snapshot)
    }

    private func prefetchAdjacentDataDays(from date: Date) {
        let calendar = Calendar.current
        for offset in [-1, 1] {
            guard let target = calendar.date(byAdding: .month, value: offset, to: date) else { continue }
            let key = monthKey(for: target)
            if dataDaysCache[key] != nil { continue }
            Task { [weak self] in
                guard let self else { return }
                let cached = await self.useCase.cachedDataDays(for: target)
                if !cached.isEmpty {
                    await MainActor.run { self.storeDataDays(cached, for: target) }
                    return
                }
                let fetched = await self.useCase.fetchDataDays(for: target)
                await MainActor.run { self.storeDataDays(fetched, for: target) }
            }
        }
    }
    
    private let monthKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}
