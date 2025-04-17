//
//  RecommendedNewsletter.swift
//  Domain
//
//  Created by 권민재 on 4/11/25.
//

import Foundation

public struct RecommendedNewsletter {
    public let union: [NewsletterDetail]
    public let intersection: [NewsletterDetail]
    
    public init(union: [NewsletterDetail], intersection: [NewsletterDetail]) {
        self.union = union
        self.intersection = intersection
    }
}
