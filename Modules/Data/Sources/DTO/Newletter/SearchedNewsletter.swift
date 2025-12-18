//
//  SearchedNewsletter.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//
import Domain
public struct SearchedNewsletterDTO: Decodable {
    let id: Int
    let brandName: String
    let firstDescription: String
    let imageUrl: String?
    
    public func toDomain() -> SearchedNewsletter {
        return SearchedNewsletter(id: String(id), brandName: brandName, firstDescription: firstDescription, imageUrl: imageUrl ?? "")
    }
}
