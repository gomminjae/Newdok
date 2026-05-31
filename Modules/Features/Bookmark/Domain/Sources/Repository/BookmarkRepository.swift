//
//  BookmarkRepository.swift
//  BookmarkDomain
//
//  Created by 권민재 on 4/11/25.
//

import Foundation

public protocol BookmarkRepository: Sendable {
    func fetchBookmarkArticles(interest: String?, sortBy: BookmarkSortOption) async throws -> BookmarkedArticles
    func changeBookmarkState(articleId: String) async throws
    func fetchBookmarkedInterest() async throws -> [BookmarkInterest]
}
