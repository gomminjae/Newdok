//
//  SubscribeViewModel.swift
//  Subscribe
//
//  Created by 권민재 on 5/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import Foundation
import SubscribeDomain
import Shared
import Observation

public enum SubscribeState {
    case loading
    case guest
    case empty
    case data
}

@Observable
@MainActor
public final class SubscribeViewModel: ErrorHandling {
    private(set) var activeList = AnalyticsListContext(.subscribedNewsletters)
    private(set) var pausedList = AnalyticsListContext(.pausedNewsletters)
    private var failedList: AnalyticsListContext?
    func analyticsStateList(tab: Int) -> AnalyticsListContext {
        currentError == .serverError ? failedList ?? analyticsList(tab: tab) : analyticsList(tab: tab)
    }
    func analyticsList(tab: Int) -> AnalyticsListContext { tab == 0 ? activeList : pausedList }
    func analyticsState(tab: Int) -> AnalyticsContentState? {
        if isGuest { return .guest }
        if currentError == .serverError { return .failed }
        guard initialLoaded, !isLoadingActive, !isLoadingPaused, !isRefreshing else { return nil }
        guard filteredSubscriptions(tab: tab).isEmpty else { return .ready }
        return tab == 0 ? .noSubscriptions : .noResults
    }
    public let analytics: AnalyticsClient

    private let fetchActiveUseCase: FetchActiveSubscriptionUseCase
    private let fetchPausedUseCase: FetchPausedSubscriptionUseCase
    private let pauseUseCase: PauseSubscriptionUseCase
    private let resumeUseCase: ResumeSubscriptionUseCase
    private let appState: AppState

    public var activeNewsletters: [SubscribeNewsletter] = []
    public var pausedNewsletters: [SubscribeNewsletter] = []

    public var initialLoaded: Bool = false
    public var isRefreshing: Bool = false
    public var isLoadingActive: Bool = false
    public var isLoadingPaused: Bool = false
    public var currentError: AppError?
    public private(set) var pendingSubscriptionIds: Set<String> = []

    private var sessionID = UUID()
    func resetForAuthChange() {
        sessionID = UUID()
        failedList = nil
        initialLoaded = false
        isLoadingActive = false
        isLoadingPaused = false
        isRefreshing = false
        activeNewsletters = []
        pausedNewsletters = []
        activeList = .init(.subscribedNewsletters)
        pausedList = .init(.pausedNewsletters)
        currentError = nil
    }
    private var lastRefreshTime = Date.distantPast
    private let refreshCooldown: TimeInterval = 2.0

    public init(
        fetchActiveUseCase: FetchActiveSubscriptionUseCase,
        fetchPausedUseCase: FetchPausedSubscriptionUseCase,
        pauseUseCase: PauseSubscriptionUseCase,
        resumeUseCase: ResumeSubscriptionUseCase,
        appState: AppState = .shared,
        analytics: AnalyticsClient = .disabled
    ) {
        self.analytics = analytics
        self.fetchActiveUseCase = fetchActiveUseCase
        self.fetchPausedUseCase = fetchPausedUseCase
        self.pauseUseCase = pauseUseCase
        self.resumeUseCase = resumeUseCase
        self.appState = appState
    }

    private var isGuest: Bool { appState.authState == .guest }

    public func filteredSubscriptions(tab: Int) -> [SubscribeNewsletter] {
        guard initialLoaded else { return [] }
        return tab == 0 ? activeNewsletters : pausedNewsletters
    }

    public func subscribeState(tab: Int) -> SubscribeState {
        if !initialLoaded {
            return .loading
        }
        if isGuest {
            return .guest
        }
        if filteredSubscriptions(tab: tab).isEmpty {
            return .empty
        }
        return .data
    }

    public func canRefresh(referenceDate: Date = Date()) -> Bool {
        guard referenceDate.timeIntervalSince(lastRefreshTime) >= refreshCooldown else {
            return false
        }
        lastRefreshTime = referenceDate
        return true
    }

    public func loadInitial() async {
        guard !isGuest else { initialLoaded = true; return }
        guard !initialLoaded else { return }
        guard !isLoadingActive && !isLoadingPaused else { return }
        activeList = .init(.subscribedNewsletters)
        pausedList = .init(.pausedNewsletters)
        let session = sessionID
        var requestedList = activeList
        isLoadingActive = true
        isLoadingPaused = true
        defer {
            if session == sessionID { isLoadingActive = false; isLoadingPaused = false }
        }

        do {
            async let active = fetchActiveUseCase.execute()
            async let paused = fetchPausedUseCase.execute()

            let activeResult = try await active
            requestedList = pausedList
            let pausedResult = try await paused
            try Task.checkCancellation()
            guard session == sessionID else { return }
            activeNewsletters = activeResult
            pausedNewsletters = pausedResult
            initialLoaded = true
            failedList = nil
            currentError = nil
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled, session == sessionID else { return }
            failedList = requestedList
            analytics.record(.operationFailed(.list(requestedList), category: .init(error: error)), from: .subscriptions)
            handleError(error, feature: "subscribe", operation: "loadInitial")
        }
    }

    public func refresh(tab: Int) async {
        guard !isRefreshing, !isGuest else { return }
        let session = sessionID
        let context = AnalyticsListContext(tab == 0 ? .subscribedNewsletters : .pausedNewsletters)
        isRefreshing = true
        defer { if session == sessionID { isRefreshing = false } }
        do {
            let result = try await (tab == 0 ? fetchActiveUseCase.execute() : fetchPausedUseCase.execute())
            try Task.checkCancellation()
            guard session == sessionID else { return }
            if tab == 0 { activeNewsletters = result; activeList = context }
            else { pausedNewsletters = result; pausedList = context }
            failedList = nil
            currentError = nil
        } catch {
            guard session == sessionID, !Task.isCancelled, !(error is CancellationError) else { return }
            failedList = context
            analytics.record(.operationFailed(.list(context), category: .init(error: error)), from: .subscriptions)
            handleError(error, feature: "subscribe", operation: "refresh")
        }
    }

    public func pause(newsletterId: String) async -> Bool {
        guard beginSubscriptionMutation(newsletterId) else { return false }
        defer { endSubscriptionMutation(newsletterId) }

        do {
            try await pauseUseCase.execute(newsletterId: newsletterId)
            currentError = nil
            return true
        } catch let error as SubscribeError {
            currentError = .userMessage(error.localizedDescription)
            return false
        } catch {
            handleError(error, feature: "subscribe", operation: "pause")
            return false
        }
    }

    public func resume(newsletterId: String) async -> Bool {
        guard beginSubscriptionMutation(newsletterId) else { return false }
        defer { endSubscriptionMutation(newsletterId) }

        do {
            try await resumeUseCase.execute(newsletterId: newsletterId)
            currentError = nil
            return true
        } catch let error as SubscribeError {
            currentError = .userMessage(error.localizedDescription)
            return false
        } catch {
            handleError(error, feature: "subscribe", operation: "resume")
            return false
        }
    }

    public func isSubscriptionPending(_ newsletterId: String) -> Bool {
        pendingSubscriptionIds.contains(newsletterId)
    }

    private func beginSubscriptionMutation(_ newsletterId: String) -> Bool {
        guard !pendingSubscriptionIds.contains(newsletterId) else { return false }
        pendingSubscriptionIds.insert(newsletterId)
        return true
    }

    private func endSubscriptionMutation(_ newsletterId: String) {
        pendingSubscriptionIds.remove(newsletterId)
    }
}
