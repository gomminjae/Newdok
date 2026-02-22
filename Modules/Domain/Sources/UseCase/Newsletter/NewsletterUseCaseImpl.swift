//
//  NewsletterUseCaseImpl.swift
//  Domain
//
//  Created by 권민재 on 4/24/25.
//

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
        return try await repository.fetchRecommendation()
    }
    
    public func searchNewsletter(brandName: String) async throws -> [Domain.Newsletter] {
        return try await repository.searchNewsletter(brandName: brandName)
    }
    
    public func fetchNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [Domain.Brand] {
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
    
    public func fetchGuestNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [Domain.Brand] {
        return try await repository.fetchGuestAllNewsletters(orderOpt: orderOpt, industry: industry, day: day)
    }
    
    public func fetchGuestNewsletterBrand(id: String) async throws -> Domain.BrandDetail {
        return try await repository.fetchGuestNewsletterBrand(id: id)
    }
    
    public func fetchSubscriptionCount() async throws -> Int {
        return try await repository.fetchSubscriptionCount()
    }

    public func fetchOptionList() async throws -> Domain.OptionList {
        return try await repository.fetchOptionList()
    }
}
