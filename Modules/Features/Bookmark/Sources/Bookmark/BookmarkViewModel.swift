//
//  BookmarkViewModel.swift
//  Bookmark
//
//  Created by 권민재 on 5/2/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import Foundation
import SwiftUI
import BookmarkDomain
import Shared
import Observation

protocol BookmarkViewModelBindable {
    func fetchUserInterests() async
    func fetchUserBookmarks() async
}

@Observable
@MainActor
public final class BookmarkViewModel: BookmarkViewModelBindable, ErrorHandling {
    public var interest: String = ""
    public var interests: [BookmarkInterest] = []

    public var bookmarks: BookmarkedArticles?
    public var sortOrder: BookmarkSortOption = .bookmarkDate
    public var currentError: AppError?

    private let fetchArticlesUseCase: FetchBookmarkedArticlesUseCase
    private let toggleBookmarkUseCase: ToggleBookmarkStatusUseCase
    private let fetchInterestsUseCase: FetchBookmarkedInterestsUseCase

    public init(
        fetchArticlesUseCase: FetchBookmarkedArticlesUseCase,
        toggleBookmarkUseCase: ToggleBookmarkStatusUseCase,
        fetchInterestsUseCase: FetchBookmarkedInterestsUseCase
    ) {
        self.fetchArticlesUseCase = fetchArticlesUseCase
        self.toggleBookmarkUseCase = toggleBookmarkUseCase
        self.fetchInterestsUseCase = fetchInterestsUseCase
    }

    // MARK: - 정렬된 북마크 데이터 (API에서 정렬된 데이터 사용)
    public var sortedBookmarks: BookmarkedArticles? {
        return bookmarks
    }

    private var loadTask: Task<Void, Never>?

    func cancelLoads() { loadTask?.cancel(); loadTask = nil }

    func fetchUserInterests() async {
        await performAsync(feature: "bookmark", operation: "fetchUserInterests") {
            interests = try await fetchInterestsUseCase.execute()
        }
    }

    func fetchUserBookmarks() async {
        await performAsync(feature: "bookmark", operation: "fetchUserBookmarks") {
            bookmarks = try await fetchArticlesUseCase.execute(interest: interest, sortBy: sortOrder)
        }
    }

    // 최초 로드: 관심사/목록 병렬 + 스켈레톤 표시용 플래그
    public var isLoading: Bool = false
    func loadInitial() {
        cancelLoads()
        loadTask = Task { @MainActor in
            await performAsync(feature: "bookmark", operation: "loadInitial", loadingBinding: \.isLoading) {
                async let fetchedInterests = fetchInterestsUseCase.execute()
                async let fetchedArticles = fetchArticlesUseCase.execute(interest: interest, sortBy: sortOrder)
                self.interests = try await fetchedInterests
                self.bookmarks = try await fetchedArticles
            }
        }
    }

    // 로그아웃 시 데이터 초기화
    func clearData() {
        interest = ""
        interests = []
        bookmarks = nil
        sortOrder = .bookmarkDate
    }
}
