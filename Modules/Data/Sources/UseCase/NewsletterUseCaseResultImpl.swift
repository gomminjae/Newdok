//
//  NewsletterUseCaseResultImpl.swift
//  Data
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation
import Domain
import Shared

public final class NewsletterUseCaseResultImpl: NewsletterUseCaseResult {
    
    private let repository: NewsletterRepositoryResult
    
    public init(repository: NewsletterRepositoryResult) {
        self.repository = repository
    }
    
    // MARK: - UseCase Methods with Result
    
    public func fetchActiveSubscription() async -> AppResult<[Newsletter]> {
        return await repository.fetchActiveSubscription()
    }
    
    public func fetchPausedSubscription() async -> AppResult<[Newsletter]> {
        return await repository.fetchPausedSubscription()
    }
    
    public func fetchRecommendation() async -> AppResult<RecommendedNewsletter> {
        return await repository.fetchRecommendation()
    }
    
    public func searchNewsletter(brandName: String) async -> AppResult<[Newsletter]> {
        let validationResult = validateBrandName(brandName)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.searchNewsletter(brandName: brandName)
    }
    
    public func fetchNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async -> AppResult<[Brand]> {
        let validationResult = validateFilterOptions(orderOpt: orderOpt, industry: industry, day: day)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.fetchNewsletters(orderOpt: orderOpt, industry: industry, day: day)
    }
    
    public func fetchNewsletterBrand(id: String) async -> AppResult<BrandDetail> {
        let validationResult = validateNewsletterId(id)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.fetchNewsletterBrand(id: id)
    }
    
    public func pauseSubscription(newsletterId: String) async -> AppResult<Void> {
        let validationResult = validateNewsletterId(newsletterId)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.pauseSubscription(newsletterId: newsletterId)
    }
    
    public func resumeSubscription(newsletterId: String) async -> AppResult<Void> {
        let validationResult = validateNewsletterId(newsletterId)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.resumeSubscription(newsletterId: newsletterId)
    }
    
    public func fetchGuestNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async -> AppResult<[Brand]> {
        let validationResult = validateFilterOptions(orderOpt: orderOpt, industry: industry, day: day)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.fetchGuestNewsletters(orderOpt: orderOpt, industry: industry, day: day)
    }
    
    public func fetchGuestNewsletterBrand(id: String) async -> AppResult<BrandDetail> {
        let validationResult = validateNewsletterId(id)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.fetchGuestNewsletterBrand(id: id)
    }
    
    public func fetchSubscriptionCount() async -> AppResult<Int> {
        return await repository.fetchSubscriptionCount()
    }
} 