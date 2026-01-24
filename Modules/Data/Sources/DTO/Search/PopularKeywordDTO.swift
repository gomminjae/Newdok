//
//  PopularKeywordDTO.swift
//  Data
//
//  Created by 권민재 on 1/24/26.
//

import Domain

public struct PopularKeywordDTO: Decodable {
    public let rank: Int
    public let keyword: String
    
    public func toDomain() -> PopularKeyword {
        PopularKeyword(rank: rank, keyword: keyword)
    }
}

public struct PopularKeywordResponseDTO: Decodable {
    public let updatedDate: String
    public let keywords: [PopularKeywordDTO]
    
    public func toDomain() -> PopularKeywordList {
        PopularKeywordList(
            updatedDate: updatedDate,
            keywords: keywords.map { $0.toDomain() }
        )
    }
}
