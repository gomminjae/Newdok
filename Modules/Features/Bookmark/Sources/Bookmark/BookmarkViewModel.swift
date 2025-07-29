//
//  BookmarkViewModel.swift
//  Bookmark
//
//  Created by 권민재 on 5/2/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import Foundation
import SwiftUI
import Domain
import Shared

protocol BookmarkViewModelBindable {
    
    func fetchUserInterests() async
    func fetchUserBookmarks() async
    
}



@MainActor
public class BookmarkViewModel: ObservableObject, BookmarkViewModelBindable {
    
    @Published public var interest: String = ""
    @Published public var interests: [Interest] = []
    
    @Published public var bookmarks: BookmarkedArticles? = nil
    @Published public var sortOrder: String = "추가순"
    
    private let useCase: ArticleUseCase
    
    public init(useCase: ArticleUseCase) {
        self.useCase = useCase
        setupDataClearing()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupDataClearing() {
        DataClearingService.shared.register { [weak self] in
            self?.clearData()
        }
    }
    
    private func clearData() {
        bookmarks = nil
        sortOrder = "추가순"
    }
    
    // MARK: - 정렬된 북마크 데이터
    public var sortedBookmarks: BookmarkedArticles? {
        guard let bookmarks = bookmarks else { return nil }
        
        let sortedMonths = bookmarks.bookmarkForMonth.map { monthData in
            let sortedBookmarks = monthData.bookmark.sorted { first, second in
                switch sortOrder {
                case "추가순":
                    // 북마크 추가 순서 (역순으로 정렬 - 최근 추가된 것이 위로)
                    return first.articleId > second.articleId
                case "최근 아티클 순":
                    // 아티클 발행일 기준 최신순
                    return first.date > second.date
                case "오래된 아티클 순":
                    // 아티클 발행일 기준 오래된순
                    return first.date < second.date
                default:
                    return first.articleId > second.articleId
                }
            }
            
            return MonthlyBookmark(
                month: monthData.month,
                bookmark: sortedBookmarks
            )
        }
        
        return BookmarkedArticles(
            totalAmount: bookmarks.totalAmount,
            bookmarkForMonth: sortedMonths
        )
    }
    
    func fetchUserInterests() async  {
        Task {
            do {
                let response = try await useCase.fetchBookmarkedInterests()
                interests = response
            }
        }
    }
    
    func fetchUserBookmarks() async {
        do {
            let response = try await useCase.fetchBookmarkedArticles(interest: interest)
            bookmarks = response
        } catch {
            print("북마크 불러오기 실패: \(error)")
        }
    }
}
