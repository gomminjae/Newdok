//
//  Explore ViewModel.swift
//  Explore
//
//  Created by 권민재 on 4/24/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import Combine
import Shared
import Domain
import SwiftUI
import Shared


@MainActor
public class ExploreViewModel: ObservableObject {
    
    @Published public var myRecommendation: [NewsletterDetail] = []
    @Published public var unionRecommendation: [NewsletterDetail] = []
    
    
    private let useCase: NewsletterUseCase
    
    public init(useCase: NewsletterUseCase) {
        self.useCase = useCase
    }
    
    
    
    
    
    
    public func fetchRecommendation() {
        Task {
            do {
                let response = try await useCase.fetchRecommendation()
                
                myRecommendation = response.intersection
                unionRecommendation = response.union
            } catch {
                print("에러")
            }
        }
    }
    
    
    
    
}
