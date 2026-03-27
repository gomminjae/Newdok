//
//  BookmarkRepository.swift
//  BookmarkDomain
//
//  Created by 권민재 on 4/11/25.
//

import Foundation

public protocol BookmarkRepository {
    func fetchBookmarkArticles(interest: String?, sortBy: String?) async throws -> BookmarkedArticles
    func changeBookmarkState(articleId: String) async throws
    func fetchBookmarkedInterest() async throws -> [BookmarkInterest]
}
