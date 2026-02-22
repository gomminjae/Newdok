//
//  SearchRepositoryImpl.swift
//  Data
//
//  Created by 권민재 on 7/13/25.
//
import Foundation
import Domain
import Core
import Moya
import Shared

public class SearchRepositoryImpl: SearchRepository {
    private let provider: MoyaProvider<SearchAPI>
    
    public init(provider: MoyaProvider<SearchAPI>) {
        self.provider = provider
    }
    
    public func searchNewsletters(brandName: String) async throws -> [Domain.SearchedNewsletter] {
        logDebug("뉴스레터 검색 - 브랜드명: \(brandName)", category: .repository)
        let response: [SearchedNewsletterDTO] = try await provider.asyncRequest(.searchNewsletters(brandName: brandName))
        logDebug("뉴스레터 검색 완료 - \(response.count)개", category: .repository)
        return response.map { $0.toDomain() }
    }
    
    public func fetchPopularKeywords() async throws -> PopularKeywordList {
        logDebug("인기 검색어 조회", category: .repository)
        let response: PopularKeywordResponseDTO = try await provider.asyncRequest(.popularKeywords)
        return response.toDomain()
    }
}
