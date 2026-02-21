//
//  RecommendedNewsletter.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

import Foundation
import Domain

public struct RecommendedNewsletterDTO: Decodable {
    let union: [NewsletterDetailDTO]
    let intersection: [NewsletterDetailDTO]
    
    public func toDomain() -> RecommendedNewsletter {
        return RecommendedNewsletter(union: union.map { $0.toDomain() }, intersection: intersection.map { $0.toDomain() })
    }
}
