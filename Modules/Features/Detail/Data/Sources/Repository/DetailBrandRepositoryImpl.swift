//
//  DetailBrandRepositoryImpl.swift
//  DetailData
//

import DetailDomain
import Core
import Moya
import Shared

public class DetailBrandRepositoryImpl: DetailBrandRepository {
    private let provider: MoyaProvider<NewsletterAPI>

    public init(provider: MoyaProvider<NewsletterAPI>) {
        self.provider = provider
    }

    public func fetchNewsletterBrand(id: String) async throws -> DetailBrandDetail {
        logDebug("브랜드 상세 조회 - ID: \(id)", category: .repository)
        let response: DetailBrandDetailDTO = try await provider.asyncRequest(.fetchNewsletterBrand(id: id))
        logDebug("브랜드 상세 조회 완료", category: .repository)
        return response.toDomain()
    }

    public func fetchGuestNewsletterBrand(id: String) async throws -> DetailBrandDetail {
        let response: DetailBrandDetailDTO = try await provider.asyncRequest(.fetchGuestNewsletterBrand(id: id))
        return response.toDomain()
    }

    public func pauseSubscription(newsletterId: String) async throws {
        try await provider.asyncVoidRequest(.pauseSubscription(newsletterId: newsletterId))
    }

    public func resumeSubscription(newsletterId: String) async throws {
        try await provider.asyncVoidRequest(.resumeSubscription(newsletterId: newsletterId))
    }
}
