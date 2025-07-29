//
//  SearchRepositoryResultImpl.swift
//  Data
//
//  Created by AI Assistant on 1/14/25.
//

import Domain
import Core
import Shared
import Moya

public final class SearchRepositoryResultImpl: SearchRepositoryResult {
    
    private let provider: MoyaProvider<SearchAPI>
    
    public init(provider: MoyaProvider<SearchAPI>) {
        self.provider = provider
    }
    
    // MARK: - Repository Methods with Result
    
    public func searchNewsletters(brandName: String) async -> AppResult<[SearchedNewsletter]> {
        return await AppResult.catching {
            let response: [SearchedNewsletterDTO] = try await self.provider.asyncRequest(.searchNewsletters(brandName: brandName))
            return response.map { $0.toDomain() }
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    public func searchArticles(keyword: String) async -> AppResult<[Bookmark]> {
        return await AppResult.catching {
            let response: [BookmarkDTO] = try await self.provider.asyncRequest(.searchArticles(keyword: keyword))
            return response.map { $0.toDomain() }
        }.mapError { error in
            self.mapToAppError(error)
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapToAppError(_ error: Error) -> AppError {
        if let networkError = error as? NetworkError {
            return .network(self.mapNetworkError(networkError))
        } else if error.localizedDescription.contains("검색") && error.localizedDescription.contains("결과") {
            return .business(.dataNotFound)
        } else if error.localizedDescription.contains("키워드") {
            return .validation(.invalidFormat("검색어"))
        } else {
            return .unknown(error.localizedDescription)
        }
    }
    
    private func mapNetworkError(_ error: NetworkError) -> NetworkError {
        return error // 이미 NetworkError이므로 그대로 반환
    }
} 