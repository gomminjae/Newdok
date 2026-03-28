//
//  BookmarkUseCase.swift
//  BookmarkDomain
//
//  Created by 권민재 on 4/11/25.
//

import Foundation

public protocol BookmarkUseCase: Sendable {
    func fetchBookmarkedArticles(interest: String?, sortBy: String?) async throws -> BookmarkedArticles
    func toggleBookmarkStatus(articleId: String) async throws
    func fetchBookmarkedInterests() async throws -> [BookmarkInterest]
}
