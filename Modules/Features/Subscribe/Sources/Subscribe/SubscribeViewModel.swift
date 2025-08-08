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

@MainActor
public final class SubscribeViewModel: ObservableObject {

    private let useCase: NewsletterUseCase

    @Published public var activeNewsletters: [Newsletter] = []
    @Published public var pausedNewsletters: [Newsletter] = []

    @Published public var initialLoaded: Bool = false
    @Published public var isRefreshing: Bool = false
    @Published public var isLoadingActive: Bool = false
    @Published public var isLoadingPaused: Bool = false
    @Published public var lastRefreshTime: Date = Date.distantPast

    public init(useCase: NewsletterUseCase) {
        self.useCase = useCase
    }

    public func loadInitial() async {
        guard !initialLoaded else { return }
        isLoadingActive = true
        isLoadingPaused = true
        async let active = useCase.fetchActiveSubscription()
        async let paused = useCase.fetchPausedSubscription()
        do {
            activeNewsletters = try await active
            pausedNewsletters = try await paused
        } catch {
            print("초기 로딩 실패:", error)
        }
        isLoadingActive = false
        isLoadingPaused = false
        initialLoaded = true
    }

    public func refresh(tab: Int) async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            if tab == 0 {
                activeNewsletters = try await useCase.fetchActiveSubscription()
            } else {
                pausedNewsletters = try await useCase.fetchPausedSubscription()
            }
        } catch {
            print("리프레시 실패:", error)
        }
    }

    public func pause(newsletterId: String) async {
        do {
            _ = try await useCase.pauseSubscription(newsletterId: newsletterId)
        } catch {
            print("pause 실패:", error)
        }
    }

    public func resume(newsletterId: String) async {
        do {
            _ = try await useCase.resumeSubscription(newsletterId: newsletterId)
        } catch {
            print("resume 실패:", error)
        }
    }
}
