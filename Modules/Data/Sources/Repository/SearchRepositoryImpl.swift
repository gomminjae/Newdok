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
    
    
    public func searchArticles(brandName: String) async throws -> [Domain.SearchedNewsletter] {
        let response: [SearchedNewsletterDTO] = try await provider.asyncRequest(.searchNewsletters(brandName: brandName))
        return response.map { $0.toDomain() }
    }
    
    public func searchArticles(keyword: String) async throws -> [Domain.Bookmark] {
        let response: [BookmarkDTO] = try await provider.asyncRequest(.searchArticles(keyword: keyword))
        return response.map { $0.toDomain() }
    }
    
    
}
