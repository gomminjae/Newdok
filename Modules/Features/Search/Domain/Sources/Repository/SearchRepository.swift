//
//  SearchRepository.swift
//  SearchDomain
//
//  Created by 권민재 on 7/13/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation

public protocol SearchRepository {
    func searchNewsletters(brandName: String) async throws -> [SearchedNewsletter]
    func fetchPopularKeywords() async throws -> PopularKeywordList
}
