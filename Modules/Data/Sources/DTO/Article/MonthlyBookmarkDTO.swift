//
//  MonthlyBookmarkDTO.swift
//  Data
//
//  Created by 권민재 on 4/13/25.
//
import Domain
public struct MonthlyBookmarkDTO: Decodable {
    let month: String
    let bookmark: [BookmarkDTO]
    
    public func toDomain() -> MonthlyBookmark {
        return MonthlyBookmark(month: month, bookmark: bookmark.map { $0.toDomain() })
    }
}
