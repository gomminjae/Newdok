//
//  NewsletterRepositoryResultImpl.swift
//  Data
//
//  Created by AI Assistant on 1/14/25.
//

import Domain
import Core
import Foundation
import Moya
import Shared

public final class NewsletterRepositoryResultImpl: NewsletterRepositoryResult {
    
    private let provider: MoyaProvider<NewsletterAPI>
    
    public init(provider: MoyaProvider<NewsletterAPI>) {
        self.provider = provider
    }
    
    // MARK: - Repository Methods with Result
    
    public func fetchActiveSubscription() async -> AppResult<[Newsletter]> {
        return await AppResult.catching {
            let response: [NewsletterDTO] = try await self.provider.asyncRequest(.fetchActiveSubscription)
            return response.map { $0.toDomain() }
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func fetchPausedSubscription() async -> AppResult<[Newsletter]> {
        return await AppResult.catching {
            let response: [NewsletterDTO] = try await self.provider.asyncRequest(.fetchPausedSubscription)
            return response.map { $0.toDomain() }
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func fetchSubscriptionCount() async -> AppResult<Int> {
        return await AppResult.catching {
            let response: Int = try await self.provider.asyncRequest(.fetchSubscriptionCount)
            return response
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func fetchRecommendation() async -> AppResult<RecommendedNewsletter> {
        return await AppResult.catching {
            let response: RecommendedNewsletterDTO = try await self.provider.asyncRequest(.fetchRecommendation)
            return response.toDomain()
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func searchNewsletter(brandName: String) async -> AppResult<[Newsletter]> {
        return await AppResult.catching {
            let response: [NewsletterDTO] = try await self.provider.asyncRequest(.searchNewsletter(brandName: brandName))
            return response.map { $0.toDomain() }
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func fetchNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async -> AppResult<[Brand]> {
        return await AppResult.catching {
            let response: [BrandDTO] = try await self.provider.asyncRequest(.fetchNewsletters(orderOpt: orderOpt, industry: industry, day: day))
            return response.map { $0.toDomain() }
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func fetchNewsletterBrand(id: String) async -> AppResult<BrandDetail> {
        return await AppResult.catching {
            let response: BrandDetailDTO = try await self.provider.asyncRequest(.fetchNewsletterBrand(id: id))
            return response.toDomain()
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func pauseSubscription(newsletterId: String) async -> AppResult<Void> {
        return await AppResult.catching {
            try await self.provider.asyncVoidRequest(.pauseSubscription(newsletterId: newsletterId))
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func resumeSubscription(newsletterId: String) async -> AppResult<Void> {
        return await AppResult.catching {
            try await self.provider.asyncVoidRequest(.resumeSubscription(newsletterId: newsletterId))
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func fetchGuestNewsletters(orderOpt: String?, industry: [Int]?, day: [Int]?) async -> AppResult<[Brand]> {
        return await AppResult.catching {
            let response: [BrandDTO] = try await self.provider.asyncRequest(.fetchGuestNewsletters(orderOpt: orderOpt, industry: industry, day: day))
            return response.map { $0.toDomain() }
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func fetchGuestNewsletterBrand(id: String) async -> AppResult<BrandDetail> {
        return await AppResult.catching {
            let response: BrandDetailDTO = try await self.provider.asyncRequest(.fetchGuestNewsletterBrand(id: id))
            return response.toDomain()
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapToAppError(_ error: Error) -> AppError {
        if let networkError = error as? NetworkError {
            return .network(self.mapNetworkError(networkError))
        } else if error.localizedDescription.contains("구독") {
            return .business(.operationNotAllowed)
        } else if error.localizedDescription.contains("찾을 수 없") {
            return .business(.dataNotFound)
        } else {
            return .unknown(error.localizedDescription)
        }
    }
    
    private func mapNetworkError(_ error: NetworkError) -> NetworkError {
        return error // 이미 NetworkError이므로 그대로 반환
    }
} 