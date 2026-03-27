//
//  BookmarkInterestDTO.swift
//  BookmarkData
//
//  Created by 권민재 on 4/13/25.
//

import BookmarkDomain

struct BookmarkInterestDTO: Decodable {
    let id: Int
    let name: String

    func toDomain() -> BookmarkInterest {
        return BookmarkInterest(id: id, name: name)
    }
}

struct InterestListResponse: Decodable {
    let data: [BookmarkInterestDTO]
}
