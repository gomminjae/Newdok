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
public class SubscribeViewModel: ObservableObject {
    
    private let useCase: NewsletterUseCase
    
    @Published public var activeNewsletters: [Newsletter] = []
    @Published public var pausedNewsletters: [Newsletter] = []
    @Published public var isLoading: Bool = false
    
    public init(useCase: NewsletterUseCase) {
        self.useCase = useCase
    }
    
    public func fetchActive() async {
        isLoading = true
        do {
            let response = try await useCase.fetchActiveSubscription()
            activeNewsletters = response
        } catch {
            print("✅ fetchActive 실패:", error)
        }
        isLoading = false
    }
    
    public func fetchPaused() async {
        isLoading = true
        do {
            let response = try await useCase.fetchPausedSubscription()
            pausedNewsletters = response
        } catch {
            print("✅ fetchPaused 실패:", error)
        }
        isLoading = false
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
