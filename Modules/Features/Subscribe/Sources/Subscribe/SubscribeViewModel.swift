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

    public var activeNewsletters: [SubscribeNewsletter] = []
    public var pausedNewsletters: [SubscribeNewsletter] = []

    public var initialLoaded: Bool = false
    public var isRefreshing: Bool = false
    public var isLoadingActive: Bool = false
    public var isLoadingPaused: Bool = false
    public var lastRefreshTime = Date.distantPast
    public var currentError: AppError?
    public private(set) var pendingSubscriptionIds: Set<String> = []

    public init(
        fetchActiveUseCase: FetchActiveSubscriptionUseCase,
        fetchPausedUseCase: FetchPausedSubscriptionUseCase,
        pauseUseCase: PauseSubscriptionUseCase,
        resumeUseCase: ResumeSubscriptionUseCase
    ) {
        self.fetchActiveUseCase = fetchActiveUseCase
        self.fetchPausedUseCase = fetchPausedUseCase
        self.pauseUseCase = pauseUseCase
        self.resumeUseCase = resumeUseCase
    }

    public func loadInitial() async {
        guard !initialLoaded else { return }
        guard !isLoadingActive && !isLoadingPaused else { return }
        isLoadingActive = true
        isLoadingPaused = true

        do {
            async let active = fetchActiveUseCase.execute()
            async let paused = fetchPausedUseCase.execute()

            activeNewsletters = try await active
            pausedNewsletters = try await paused
        } catch {
            handleError(error, feature: "subscribe", operation: "loadInitial")
        }

        initialLoaded = true
        isLoadingActive = false
        isLoadingPaused = false
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

        let result: Void? = await performAsync(feature: "subscribe", operation: "pause") {
            try await pauseUseCase.execute(newsletterId: newsletterId)
        }
        return result != nil
    }

    public func resume(newsletterId: String) async -> Bool {
        guard beginSubscriptionMutation(newsletterId) else { return false }
        defer { endSubscriptionMutation(newsletterId) }

        let result: Void? = await performAsync(feature: "subscribe", operation: "resume") {
            try await resumeUseCase.execute(newsletterId: newsletterId)
        }
        return result != nil
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
