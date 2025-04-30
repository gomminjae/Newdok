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
    
    public func fetchActive() {
        Task {
            do {
                let response = try await useCase.fetchActiveSubscription()
                activeNewsletters = response
            }
        }
    }
    
    public func fetchPaused() {
        Task {
            do {
                let response = try await useCase.fetchPausedSubscription()
                pausedNewsletters = response
            }
        }
    }
    

    
}
