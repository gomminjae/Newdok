//
//  BookmarkedArticlesDTO.swift
//  BookmarkData
//
//  Created by 권민재 on 4/13/25.
//

import BookmarkDomain

struct BookmarkedArticlesDTO: Decodable {
    let totalAmount: Int
    let bookmarkForMonth: [MonthlyBookmarkDTO]

    func toDomain() -> BookmarkedArticles {
        return BookmarkedArticles(
            totalAmount: totalAmount,
            bookmarkForMonth: bookmarkForMonth.map { $0.toDomain() }
        )
    }
}

struct BookmarkArticlesResponse: Decodable {
    let data: BookmarkedArticlesDTO
}
