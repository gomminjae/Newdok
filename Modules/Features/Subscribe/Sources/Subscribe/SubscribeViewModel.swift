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
    
    private var useCase: NewsletterUseCase
    
    @Published open var activeNewsletters: [Newsletter] = []
    @Published open var pausedNewsletters: [Newsletter] = []
    
    public init(useCase: NewsletterUseCase) {
        self.useCase = useCase
    }
    
    public func fetchActive() async {
        Task {
            do {
                let response = try await useCase.fetchActiveSubscription()
                activeNewsletters = response
            }
        }
    }
    
    public func fetchPaused() async {
        Task {
            do {
                let response = try await useCase.fetchPausedSubscription()
                pausedNewsletters = response
            }
        }
    }
    
    public func pause(newsletterId: String) async {
        Task {
            do {
                _ = try await useCase.pauseSubscription(newsletterId: newsletterId)
            } catch {
                print("중지 실패")
            }
        }
    }
    
    public func resume(newsletterId: String) async {
        Task {
            do {
                _ = try await useCase.resumeSubscription(newsletterId: newsletterId)
            } catch {
                print("재개 실패")
            }
        }
    }
    

    
}
