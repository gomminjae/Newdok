//
//  SearchRepository.swift
//  Domain
//
//  Created by 권민재 on 7/13/25.
//

import Foundation

public protocol SearchRepository {
    func searchNewsletters(brandName: String) async throws -> [SearchedNewsletter]
    func fetchPopularKeywords() async throws -> PopularKeywordList
}
