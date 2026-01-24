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
    
    public func fetchRecommendation() async throws -> Domain.RecommendedNewsletter {
        logDebug("추천 뉴스레터 조회", category: .repository)
        
        async let unionTask: [NewsletterDetailDTO] = provider.asyncRequest(.fetchRecommendUnion)
        async let intersectionTask: [NewsletterDetailDTO] = provider.asyncRequest(.fetchRecommendIntersection)
        
        let union = try await unionTask
        let intersection = try await intersectionTask
        
        logDebug("추천 뉴스레터 조회 완료 - Union: \(union.count), Intersection: \(intersection.count)", category: .repository)
        
        let recommendedNewsletterDTO = RecommendedNewsletterDTO(union: union, intersection: intersection)
        return recommendedNewsletterDTO.toDomain()
    }
    
    public func searchNewsletter(brandName: String) async throws -> [Domain.Newsletter] {
        
        return []
        
    }
    
    public func fetchNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [Domain.Brand] {
        logDebug("전체 뉴스레터 조회 - 정렬: \(orderOpt ?? "없음")", category: .repository)
        let response: [BrandDTO] = try await provider.asyncRequest(.fetchAllNewsletterBrands(orderOpt: orderOpt, industry: industry, day: day))
        logDebug("전체 뉴스레터 조회 완료 - \(response.count)개", category: .repository)
        return response.map { $0.toDomain() }
    }
    
    public func fetchNewsletterBrand(id: String) async throws -> Domain.BrandDetail {
        logDebug("브랜드 상세 조회 - ID: \(id)", category: .repository)
        let response: BrandDetailDTO = try await provider.asyncRequest(.fetchNewsletterBrand(id: id))
        logDebug("브랜드 상세 조회 완료", category: .repository)
        return response.toDomain()
    }
    
    public func pauseSubscription(newsletterId: String) async throws {
        try await provider.asyncVoidRequest(.pauseSubscription(newsletterId: newsletterId))
    }
    
    public func resumeSubscription(newsletterId: String) async throws {
        try await provider.asyncVoidRequest(.resumeSubscription(newsletterId: newsletterId))
    }
    
    public func fetchSubscriptionCount() async throws -> Int {
        let response: NewslettersCountDTO = try await provider.asyncRequest(.fetchSubscriptionCount)
        return response.count
    }
    
    
    public func fetchGuestAllNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async throws -> [Domain.Brand] {
        let response: [BrandDTO] = try await provider.asyncRequest(.fetchGuestAllNewsletterBrand(orderOpt:  orderOpt, industry: industry, day: day))
        return response.map { $0.toDomain() }
    }
    
    public func fetchGuestNewsletterBrand(id: String) async throws -> Domain.BrandDetail {
        let response: BrandDetailDTO = try await provider.asyncRequest(.fetchGuestNewsletterBrand(id: id))
        return response.toDomain()
    }

    public func fetchOptionList() async throws -> Domain.OptionList {
        logDebug("옵션 리스트 조회", category: .repository)
        let response: OptionListDTO = try await provider.asyncRequest(.fetchOptionList)
        logDebug("옵션 리스트 조회 완료", category: .repository)
        return response.toDomain()
    }

}
