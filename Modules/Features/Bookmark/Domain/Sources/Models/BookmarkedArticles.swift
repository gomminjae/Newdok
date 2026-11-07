//
//  BookmarkedArticles.swift
//  BookmarkDomain
//
//  Created by 권민재 on 4/11/25.
//

public struct BookmarkedArticles: Sendable {
    public let totalAmount: Int
    public let bookmarkForMonth: [MonthlyBookmark]

    public init(totalAmount: Int, bookmarkForMonth: [MonthlyBookmark]) {
        self.totalAmount = totalAmount
        self.bookmarkForMonth = bookmarkForMonth
    }
}
