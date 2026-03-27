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
import Combine
import Shared

protocol BookmarkViewModelBindable {
    func fetchUserInterests() async
    func fetchUserBookmarks() async
}

@MainActor
public class BookmarkViewModel: ObservableObject, BookmarkViewModelBindable, ErrorHandling {
    @Published public var interest: String = ""
    @Published public var interests: [BookmarkInterest] = []

    @Published public var bookmarks: BookmarkedArticles?
    @Published public var sortOrder: String = "추가순"
    @Published public var currentError: AppError?

    private let useCase: BookmarkUseCase
    private var cancellables = Set<AnyCancellable>()

    public init(useCase: BookmarkUseCase) {
        self.useCase = useCase

        AppState.shared.$authState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authState in
                if authState == .guest {
                    self?.clearData()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - 정렬된 북마크 데이터 (API에서 정렬된 데이터 사용)
    public var sortedBookmarks: BookmarkedArticles? {
        return bookmarks
    }

    private var loadTask: Task<Void, Never>?

    func cancelLoads() { loadTask?.cancel(); loadTask = nil }

    func fetchUserInterests() async {
        await performAsync(feature: "bookmark", operation: "fetchUserInterests") {
            interests = try await useCase.fetchBookmarkedInterests()
        }
    }

    func fetchUserBookmarks() async {
        await performAsync(feature: "bookmark", operation: "fetchUserBookmarks") {
            let sortBy = convertSortOrderToOption(sortOrder)
            bookmarks = try await useCase.fetchBookmarkedArticles(interest: interest, sortBy: sortBy)
        }
    }

    // 최초 로드: 관심사/목록 병렬 + 스켈레톤 표시용 플래그
    @Published public var isLoading: Bool = false
    func loadInitial() {
        cancelLoads()
        loadTask = Task { @MainActor in
            await performAsync(feature: "bookmark", operation: "loadInitial", loadingBinding: \.isLoading) {
                async let fetchedInterests = useCase.fetchBookmarkedInterests()
                async let fetchedArticles = useCase.fetchBookmarkedArticles(interest: interest, sortBy: convertSortOrderToOption(sortOrder))
                self.interests = try await fetchedInterests
                self.bookmarks = try await fetchedArticles
            }
        }
    }

    // 정렬 기준을 API 형식으로 변환
    private func convertSortOrderToOption(_ sortOrder: String) -> String {
        switch sortOrder {
        case "추가순":
            return "bookmark_date"
        case "최근 아티클 순":
            return "article_date_desc"
        case "오래된 아티클 순":
            return "article_date_asc"
        default:
            return "bookmark_date"
        }
    }

    // 로그아웃 시 데이터 초기화
    private func clearData() {
        interest = ""
        interests = []
        bookmarks = nil
        sortOrder = "추가순"
    }
}
