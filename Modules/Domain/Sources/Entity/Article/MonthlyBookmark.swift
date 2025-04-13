//
//  Bookmarks.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

public struct MonthlyBookmark {
    let id: Int
    let month: String
    let bookmark: [Bookmark]
    
    public init(id: Int, month: String, bookmark: [Bookmark]) {
        self.id = id
        self.month = month
        self.bookmark = bookmark
    }
}
