//
//  SearchUseCaseImpl.swift
//  Domain
//
//  Created by 권민재 on 7/13/25.
//

import SearchDomain

public final class SearchUseCaseImpl: SearchUseCase {
    private let searchRepository: SearchRepository

    public init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }

    public func searchNewsletters(brandName: String) async throws -> [SearchedNewsletter] {
        return try await searchRepository.searchNewsletters(brandName: brandName)
    }

    public func fetchPopularKeywords() async throws -> PopularKeywordList {
        return try await searchRepository.fetchPopularKeywords()
    }
}
