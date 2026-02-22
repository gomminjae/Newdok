//
//  Bookmarks.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

public struct MonthlyBookmark: Identifiable {
    public var id: String { month }
    
    public let month: String
    public let bookmark: [Bookmark]
    
    public init(month: String, bookmark: [Bookmark]) {
        self.month = month
        self.bookmark = bookmark
    }
}
