//
//  HomeViewModel.swift
//  Home
//
//  Created by 권민재 on 4/16/25. 
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import HomeDomain
import Shared
import Foundation
import Observation

// MARK: - Calendar State (Value Type — struct로 배치 업데이트, objectWillChange 1회)
public struct CalendarState {
    public var selectedDate: Date
    public var displayedMonth: Date
    public var dataDays: Set<Int> = []
    public var isLoading: Bool = false

    public init(initialDate: Date = Date()) {
        self.selectedDate = initialDate
        self.displayedMonth = initialDate
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

@Observable
@MainActor
public final class HomeViewModel {
    private let useCase: HomeBusinessUseCase
    private let appState: AppState
    private var isApplyingSnapshot = false
    public var calendarState: CalendarState {
        didSet {
            guard !isApplyingSnapshot else { return }
            let oldMonth = oldValue.displayedMonth
            let newMonth = calendarState.displayedMonth
            guard !Calendar.current.isDate(oldMonth, equalTo: newMonth, toGranularity: .month) else { return }
            applyDataDaysForMonth(newMonth)
            monthLoadTask?.cancel()
            monthLoadTask = Task { [weak self] in
                await self?.loadMonthData(for: newMonth)
            }
        }
    }
    private var monthLoadTask: Task<Void, Never>?

    public var homeState: HomeState = .idle
    public var filteredArticles: [HomeArticle] = []
    public var subscribedNewsletters: [HomeNewsletter] = []
    public var articlesByMonth: [HomeArticles] = []

    private var dataDaysCache: [String: Set<Int>] = [:]
    private var latestMonthRequestKey: String?
    private var latestDateSelectionKey: String?

    private var isGuest: Bool { appState.authState == .guest }

    public init(useCase: HomeBusinessUseCase, appState: AppState) {
        self.useCase = useCase
        self.appState = appState
        self.calendarState = CalendarState()

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
        selectedDate.newdokHomeDisplayText
    }
    
    // MARK: - Intent Handlers
    public func loadToday() async {
        guard !isGuest else {
            homeState = .guest
            return
        }
        latestDateSelectionKey = nil
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
        let selectionKey = dayKey(for: date)
        latestDateSelectionKey = selectionKey
        guard !isGuest else {
            homeState = .guest
            return
        }
        Task { [weak self] in
            guard let self else { return }
            let snapshot = await useCase.selectDateWithMonthGuarantee(date)
            await MainActor.run {
                guard self.latestDateSelectionKey == selectionKey else { return }
                self.applySnapshot(snapshot)
            }
        }
    }
    
    public func refreshCurrentData() async {
        let snapshot = await useCase.refreshCurrentData()
        applySnapshot(snapshot)
    }
    
    public func refreshToToday() async {
        guard !isGuest else {
            homeState = .guest
            return
        }
        latestDateSelectionKey = nil
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
        latestMonthRequestKey = nil
        latestDateSelectionKey = nil
        let snapshot = await useCase.resetForAuthChange()
        applySnapshot(snapshot)
        if isGuest {
            homeState = .guest
        }
    }
    
    public func shouldReloadToday(currentDate: Date = Date()) async -> Bool {
        await useCase.shouldReloadToday(currentDate: currentDate)
    }
    
    // MARK: - Snapshot Application (CalendarState를 struct 일괄 대입 → objectWillChange 1회)
    public func refreshHighlights() async {
        let snapshot = await useCase.refreshHighlightCounts()
        applySnapshot(snapshot)
    }

    private func applySnapshot(_ snapshot: HomeSnapshot) {
        isApplyingSnapshot = true
        defer { isApplyingSnapshot = false }

        var newCal = calendarState
        newCal.selectedDate = snapshot.selectedDate
        newCal.displayedMonth = snapshot.displayedMonth
        newCal.dataDays = snapshot.dataDays
        newCal.isLoading = snapshot.isCalendarLoading
        calendarState = newCal

        storeDataDays(snapshot.dataDays, for: snapshot.displayedMonth)
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
        guard !isGuest else { return [] }

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
        date.newdokMonthKey
    }

    private func dayKey(for date: Date) -> String {
        date.newdokDayKey
    }
    
    private func performMonthRequest(for date: Date, loader: @escaping () async -> HomeSnapshot) async {
        guard !isGuest else {
            calendarState.isLoading = false
            homeState = .guest
            return
        }
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
    
}
