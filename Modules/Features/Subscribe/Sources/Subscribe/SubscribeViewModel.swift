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
    private let useCase: SubscribeUseCase

    public var activeNewsletters: [SubscribeNewsletter] = []
    public var pausedNewsletters: [SubscribeNewsletter] = []

    public var initialLoaded: Bool = false
    public var isRefreshing: Bool = false
    public var isLoadingActive: Bool = false
    public var isLoadingPaused: Bool = false
    public var lastRefreshTime = Date.distantPast
    public var currentError: AppError?

    public init(useCase: SubscribeUseCase) {
        self.useCase = useCase
    }

    public func loadInitial() async {
        guard !initialLoaded else { return }
        isLoadingActive = true
        isLoadingPaused = true

        do {
            async let active = useCase.fetchActiveSubscription()
            async let paused = useCase.fetchPausedSubscription()

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
        await performAsync(feature: "subscribe", operation: "refresh", loadingBinding: \.isRefreshing) {
            if tab == 0 {
                activeNewsletters = try await useCase.fetchActiveSubscription()
            } else {
                pausedNewsletters = try await useCase.fetchPausedSubscription()
            }
        }
    }

    public func pause(newsletterId: String) async {
        await performAsync(feature: "subscribe", operation: "pause") {
            _ = try await useCase.pauseSubscription(newsletterId: newsletterId)
        }
    }

    public func resume(newsletterId: String) async {
        await performAsync(feature: "subscribe", operation: "resume") {
            _ = try await useCase.resumeSubscription(newsletterId: newsletterId)
        }
    }
}
