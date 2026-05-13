//
//  PopularKeywordDTO.swift
//  SearchData
//
//  Created by 권민재 on 1/24/26.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SearchDomain

public struct PopularKeywordDTO: Decodable, Sendable {
    public let rank: Int
    public let keyword: String

    public func toDomain() -> PopularKeyword {
        PopularKeyword(rank: rank, keyword: keyword)
    }
}

public struct PopularKeywordResponseDTO: Decodable, Sendable {
    public let updatedDate: String
    public let keywords: [PopularKeywordDTO]

    public func toDomain() -> PopularKeywordList {
        PopularKeywordList(
            updatedDate: updatedDate,
            keywords: keywords.map { $0.toDomain() }
        )
    }
}
