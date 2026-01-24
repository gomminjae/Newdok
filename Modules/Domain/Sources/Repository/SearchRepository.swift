//
//  SearchRepository.swift
//  Domain
//
//  Created by 권민재 on 7/13/25.
//

import Foundation

public protocol SearchRepository {
    func searchArticles(brandName: String) async throws -> [SearchedNewsletter]
    func searchArticles(keyword: String) async throws -> [Bookmark]
    func fetchPopularKeywords() async throws -> PopularKeywordList
}
