//
//  PopularKeyword.swift
//  SearchDomain
//
//  Created by 권민재 on 1/24/26.
//  Copyright © 2025 Newdok. All rights reserved.
//

public struct PopularKeyword: Identifiable {
    public let rank: Int
    public let keyword: String

    public var id: Int { rank }

    public init(rank: Int, keyword: String) {
        self.rank = rank
        self.keyword = keyword
    }
}

public struct PopularKeywordList {
    public let updatedDate: String
    public let keywords: [PopularKeyword]

    public init(updatedDate: String, keywords: [PopularKeyword]) {
        self.updatedDate = updatedDate
        self.keywords = keywords
    }
}
