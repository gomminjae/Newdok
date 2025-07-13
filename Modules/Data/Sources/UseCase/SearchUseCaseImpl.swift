//
//  SearchUseCaseImpl.swift
//  Data
//
//  Created by 권민재 on 7/13/25.
//

import Domain


public final class SearchUseCaseImpl: SearchUseCase {
    
    private let searchRepository: SearchRepository
    
    public init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }
    
    
    public func searchNewsletters(brandName: String) async throws -> [Domain.SearchedNewsletter] {
        return try await searchRepository.searchArticles(brandName: brandName)
    }
    
    public func searchArticles(keyword: String) async throws -> [Domain.Bookmark] {
        return try await searchRepository.searchArticles(keyword: keyword)
    }

}
