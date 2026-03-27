//
//  BookmarkDTO.swift
//  BookmarkData
//
//  Created by 권민재 on 4/13/25.
//

import BookmarkDomain

struct BookmarkDTO: Decodable {
    let brandName: String
    let brandId: Int
    let articleTitle: String
    let articleId: Int
    let sampleText: String?
    let date: String
    let imageURL: String?

    func toDomain() -> BookmarkItem {
        return BookmarkItem(
            brandName: brandName,
            brandId: brandId,
            articleTitle: articleTitle,
            articleId: articleId,
            sampleText: sampleText ?? "",
            date: date,
            imageURL: imageURL ?? ""
        )
    }
}
