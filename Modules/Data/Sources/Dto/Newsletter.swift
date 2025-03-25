//
//  Newsletter.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//

import Foundation

struct Newsletter: Decodable {
    let id: Int
    let brandName: String
    let imageUrl: String
    let publicationCycle: String
}
