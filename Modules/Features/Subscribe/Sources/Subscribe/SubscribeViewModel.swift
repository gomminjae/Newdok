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

@MainActor
public class SubscribeViewModel: ObservableObject {
    
    private let useCase: NewsletterUseCase
    
    @Published public var activeNewsletters: [Newsletter] = []
    @Published public var pausedNewsletters: [Newsletter] = []
    
    public init(useCase: NewsletterUseCase) {
        self.useCase = useCase
        setupDataClearing()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupDataClearing() {
        DataClearingService.shared.register { [weak self] in
            self?.clearData()
        }
    }
    
    private func clearData() {
        activeNewsletters = []
        pausedNewsletters = []
    
    }
    
    public func fetchActive() async {
        do {
            let response = try await useCase.fetchActiveSubscription()
            activeNewsletters = response
        } catch {
            print("✅ fetchActive 실패:", error)
        }
    }
    
    public func fetchPaused() async {
        do {
            let response = try await useCase.fetchPausedSubscription()
            pausedNewsletters = response
        } catch {
            print("✅ fetchPaused 실패:", error)
        }
    }
    
    public func pause(newsletterId: String) async {
        do {
            _ = try await useCase.pauseSubscription(newsletterId: newsletterId)
        } catch {
            print("✅ pause 실패:", error)
        }
    }
    
    public func resume(newsletterId: String) async {
        do {
            _ = try await useCase.resumeSubscription(newsletterId: newsletterId)
        } catch {
            print("✅ resume 실패:", error)
        }
    }
}
