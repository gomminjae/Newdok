//
//  Newsletter.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

import Foundation
import Domain

public struct NewsletterDTO: Decodable {
    let id: Int?
    let brandName: String
    let imageUrl: String
    let publicationCycle: String?
    
    public func toDomain() -> Newsletter {
        return Newsletter(
            id: id ?? 0,
            brandName: brandName,
            imageUrl: imageUrl,
            publicationCycle: publicationCycle ?? ""
        )
    }
}
