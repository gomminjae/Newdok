//
//  Brand.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//


import Foundation

struct NewsLetter: Codable {
    let brandId: Int
    let brandName: String
    let briefDescription: String
    let publicationCycle: String
    let subscribeUrl: String
    let imageUrl: String
    let interests: [Interest]
}

struct Interest: Codable {
    let id: Int
    let name: String
}
