//
//  NewsletterUseCaseImpl.swift
//  Data
//
//  Created by 권민재 on 4/24/25.
//

import Domain
import Core
import Shared

public class NewsletterUseCaseImpl: NewsletterUseCase {
    
    private let repository: NewsletterRepository
    
    public init(repository: NewsletterRepository) {
        self.repository = repository
    }
    
    public func fetchActiveSubscription() async throws -> [Domain.Newsletter] {
        return try await repository.fetchActiveSubscription()
    }
    
    public func fetchPausedSubscription() async throws -> [Domain.Newsletter] {
        return try await repository.fetchPausedSubscription()
    }
    
    public func fetchRecommendation() async throws -> Domain.RecommendedNewsletter {
        return try await repository.fetchRecommenidation()
    }
    
    public func searchNewsletter(brandName: String) async throws -> [Domain.Newsletter] {
        return try await repository.searchNewsletter(brandName: brandName)
    }
    
    public func fetchNewsletters(orderOpt: String?, industry: String?, day: String?) async throws -> [Domain.Brand] {
        return try await repository.fetchNewsletters(orderOpt: orderOpt, industry: industry, day: day)
    }
    
    public func fetchNewsletterBrand(id: String) async throws -> Domain.BrandDetail {
        return try await repository.fetchNewsletterBrand(id: id)
    }
    
    public func pauseSubscription(newsletterId: String) async throws {
        return try await repository.pauseSubscription(newsletterId: newsletterId)
    }
    
    public func resumeSubscription(newsletterId: String) async throws {
        return try await repository.resumeSubscription(newsletterId: newsletterId)
    }
    
    
    
    
    
}
