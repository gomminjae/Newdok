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

    private var lastRefreshTime = Date.distantPast
    private let refreshCooldown: TimeInterval = 2.0

    public init(
        fetchActiveUseCase: FetchActiveSubscriptionUseCase,
        fetchPausedUseCase: FetchPausedSubscriptionUseCase,
        pauseUseCase: PauseSubscriptionUseCase,
        resumeUseCase: ResumeSubscriptionUseCase,
        appState: AppState = .shared
    ) {
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
        guard !initialLoaded else { return }
        guard !isLoadingActive && !isLoadingPaused else { return }
        isLoadingActive = true
        isLoadingPaused = true
        defer {
            isLoadingActive = false
            isLoadingPaused = false
        }

        do {
            async let active = fetchActiveUseCase.execute()
            async let paused = fetchPausedUseCase.execute()

            activeNewsletters = try await active
            pausedNewsletters = try await paused
            initialLoaded = true
            currentError = nil
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            handleError(error, feature: "subscribe", operation: "loadInitial")
        }
    }

    public func refresh(tab: Int) async {
        guard !isRefreshing else { return }
        await performAsync(feature: "subscribe", operation: "refresh", loadingBinding: \.isRefreshing) {
            if tab == 0 {
                activeNewsletters = try await fetchActiveUseCase.execute()
            } else {
                pausedNewsletters = try await fetchPausedUseCase.execute()
            }
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
