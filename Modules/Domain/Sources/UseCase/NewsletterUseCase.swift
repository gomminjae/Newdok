//
//  NewsletterUseCase.swift
//  Domain
//
//  Created by 권민재 on 4/24/25.
//

import Foundation
import Shared

public protocol NewsletterUseCase {
    
    func fetchActiveSubscription() async throws -> [Newsletter]
    func fetchPausedSubscription() async throws -> [Newsletter]
    
    
    func fetchRecommendation() async throws -> RecommendedNewsletter
    
  
    func searchNewsletter(brandName: String) async throws -> [Newsletter]
    
    
    
    func fetchNewsletters(orderOpt: String, industry: String, day: String) async throws -> [Brand]
    
    func fetchNewsletterBrand(id: String) async throws -> BrandDetail
    
    func pauseSubscription(newsletterId: String) async throws
    func resumeSubscription(newsletterId: String) async throws
    
}
