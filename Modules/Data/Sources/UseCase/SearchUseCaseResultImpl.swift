//
//  SearchUseCaseResultImpl.swift
//  Data
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation
import Domain
import Shared

public final class SearchUseCaseResultImpl: SearchUseCaseResult {
    
    private let repository: SearchRepositoryResult
    
    public init(repository: SearchRepositoryResult) {
        self.repository = repository
    }
    
    // MARK: - UseCase Methods with Result
    
    public func searchNewsletters(brandName: String) async -> AppResult<[SearchedNewsletter]> {
        let validationResult = validateBrandSearchName(brandName)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.searchNewsletters(brandName: brandName)
    }
    
    public func searchArticles(keyword: String) async -> AppResult<[Bookmark]> {
        let validationResult = validateSearchKeyword(keyword)
        if case .failure(let error) = validationResult {
            return .failure(error)
        }
        
        return await repository.searchArticles(keyword: keyword)
    }
} 