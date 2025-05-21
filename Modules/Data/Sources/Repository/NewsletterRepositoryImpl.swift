//
//  NewsletterRepositoryImpl.swift
//  Data
//
//  Created by 권민재 on 4/18/25.
//

import Domain
import Core
import Shared
import Moya


public class NewsletterRepositoryImpl: NewsletterRepository {
  
    
    private let provider: MoyaProvider<NewsletterAPI>
    
    public init(provider: MoyaProvider<NewsletterAPI>) {
        self.provider = provider
    }
    

    public func fetchActiveSubscription() async throws -> [Domain.Newsletter] {
        let response: [NewsletterDTO] = try await provider.asyncRequest(.fetchActiveNewletters)
        return response.map { $0.toDomain() }
    }
    
    public func fetchPausedSubscription() async throws -> [Domain.Newsletter] {
        let response: [NewsletterDTO] = try await provider.asyncRequest(.fetchPausedNewletters)
        return response.map { $0.toDomain() }
    }
    
    public func fetchRecommenidation() async throws -> Domain.RecommendedNewsletter {
        let response: RecommendedNewsletterDTO = try await provider.asyncRequest(.fetchRecommendationList)
        return response.toDomain()
    }
    
    public func searchNewsletter(brandName: String) async throws -> [Domain.Newsletter] {
        
        return []
        
    }
    
    public func fetchNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [Domain.Brand] {
        let response: [BrandDTO] = try await provider.asyncRequest(.fetchAllNewsletterBrands(orderOpt: orderOpt, industry: industry, day: day))
        return response.map { $0.toDomain() }
    }
    
    public func fetchNewsletterBrand(id: String) async throws -> Domain.BrandDetail {
        let response: BrandDetailDTO = try await provider.asyncRequest(.fetchNewsletterBrand(id: id))
        return response.toDomain()
    }
    
    public func pauseSubscription(newsletterId: String) async throws {
        try await provider.asyncVoidRequest(.pauseSubscription(newsletterId: newsletterId))
    }
    
    public func resumeSubscription(newsletterId: String) async throws {
        try await provider.asyncVoidRequest(.resumeSubscription(newsletterId: newsletterId))
    }
    
    
    public func fetchGuestAllNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [Domain.Brand] {
        let response: [BrandDTO] = try await provider.asyncRequest(.fetchGuestAllNewsletterBrand(orderOpt:  orderOpt, industry: industry, day: day))
        return response.map { $0.toDomain() }
    }
    
    public func fetchGuestNewsletterBrand(id: String) async throws -> Domain.BrandDetail {
        let response: BrandDetailDTO = try await provider.asyncRequest(.fetchGuestNewsletterBrand(id: id))
        return response.toDomain()
    }
    
    
    
}
