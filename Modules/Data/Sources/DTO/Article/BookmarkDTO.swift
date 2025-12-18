//
//  BookmarkDTO.swift
//  Data
//
//  Created by 권민재 on 4/13/25.
//
import Domain
public struct BookmarkDTO: Decodable {
    let brandName: String
    let brandId: Int
    let articleTitle: String
    let articleId: Int
    let sampleText: String?
    let date: String
    let imageURL: String?
    
    public func toDomain() -> Bookmark {
        return Bookmark(brandName: brandName, brandId: brandId, articleTitle: articleTitle, articleId: articleId, sampleText: sampleText ?? "", date: date, imageURL: imageURL ?? "")
    }
}
