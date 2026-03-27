//
//  MonthlyBookmark.swift
//  BookmarkDomain
//
//  Created by 권민재 on 4/11/25.
//

public struct MonthlyBookmark: Identifiable {
    public var id: String { month }
    public let month: String
    public let bookmark: [BookmarkItem]

    public init(month: String, bookmark: [BookmarkItem]) {
        self.month = month
        self.bookmark = bookmark
    }
}
