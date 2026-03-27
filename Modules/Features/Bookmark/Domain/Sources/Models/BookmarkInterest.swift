//
//  BookmarkInterest.swift
//  BookmarkDomain
//
//  Created by 권민재 on 4/11/25.
//

public struct BookmarkInterest: Identifiable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
