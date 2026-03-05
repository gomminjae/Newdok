//
//  SubscribeViewModel.swift
//  Subscribe
//
//  Created by 권민재 on 5/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import Foundation
import Domain
import Shared

public enum SubscribeState {
    case loading
    case guest
    case empty
    case data
}

@MainActor
public final class SubscribeViewModel: ObservableObject, ErrorHandling {
    private let useCase: NewsletterUseCase

    @Published public var activeNewsletters: [Newsletter] = []
    @Published public var pausedNewsletters: [Newsletter] = []

    @Published public var initialLoaded: Bool = false
    @Published public var isRefreshing: Bool = false
    @Published public var isLoadingActive: Bool = false
    @Published public var isLoadingPaused: Bool = false
    @Published public var lastRefreshTime = Date.distantPast
    @Published public var currentError: AppError?

    public init(useCase: NewsletterUseCase) {
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
