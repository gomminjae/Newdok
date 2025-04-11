//
//  NewsletterDetail.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

public struct NewsletterDetail {
    let id: Int
    let brandName: String
    let firstDescription: String
    let secondDescription: String
    let publicationCycle: String
    let subscribeUrl: String
    let imageUrl: String
    let createdAt: String
    let updatedAt: String
    let industries: [Industry]
    let interests: [Interest]
}
