//
//  BookmarkedArticles.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

public struct BookmarkedArticles {
    public let totalAmount: Int
    public let bookmarkForMonth: [MonthlyBookmark]
    
    public init(totalAmount: Int, bookmarkForMonth: [MonthlyBookmark]) {
        self.totalAmount = totalAmount
        self.bookmarkForMonth = bookmarkForMonth
    }
}
