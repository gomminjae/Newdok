//
//  BookmarkViewModelResult.swift
//  Bookmark
//
//  Created by AI Assistant on 1/14/25.
//

import Foundation
import SwiftUI
import Domain
import Shared

@MainActor
public class BookmarkViewModelResult: ObservableObject {
    
    // MARK: - Dependencies
    private let useCase: ArticleUseCaseResult
    
    // MARK: - Published Properties
    @Published public var interest: String = ""
    @Published public var interests: [Interest] = []
    @Published public var bookmarks: BookmarkedArticles? = nil
    @Published public var sortOrder: String = "추가순"
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    // MARK: - Initialization
    public init(useCase: ArticleUseCaseResult) {
        self.useCase = useCase
    }
    
    // MARK: - Computed Properties
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
    
    // MARK: - Public Methods
    public func fetchUserInterests() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.fetchBookmarkedInterests()
        
        await result
            .onSuccess { [weak self] interests in
                await self?.handleInterestsSuccess(interests)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "관심사")
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func fetchUserBookmarks() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.fetchBookmarkedArticles(interest: interest.isEmpty ? nil : interest)
        
        await result
            .onSuccess { [weak self] bookmarks in
                await self?.handleBookmarksSuccess(bookmarks)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "북마크")
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func toggleBookmark(articleId: String) async -> AppResult<Void> {
        let result = await useCase.toggleBookmarkStatus(articleId: articleId)
        
        // 북마크 토글 성공 시 목록 새로고침
        if case .success = result {
            await fetchUserBookmarks()
        }
        
        return result
    }
    
    public func refreshData() async {
        await fetchUserInterests()
        await fetchUserBookmarks()
    }
    
    public func changeSortOrder(_ newOrder: String) {
        self.sortOrder = newOrder
    }
    
    public func changeInterestFilter(_ newInterest: String) async {
        self.interest = newInterest
        await fetchUserBookmarks()
    }
    
    // MARK: - Private Methods
    @MainActor
    private func handleInterestsSuccess(_ interests: [Interest]) async {
        self.interests = interests
    }
    
    @MainActor
    private func handleBookmarksSuccess(_ bookmarks: BookmarkedArticles) async {
        self.bookmarks = bookmarks
    }
    
    @MainActor
    private func handleError(_ error: AppError, context: String) async {
        switch error {
        case .network(let networkError):
            switch networkError {
            case .networkUnavailable:
                self.errorMessage = "네트워크 연결을 확인해주세요"
            case .timeout:
                self.errorMessage = "요청 시간이 초과되었습니다"
            case .serverError(let statusCode, let message):
                if statusCode == 404 {
                    self.errorMessage = "\(context) 데이터가 없습니다"
                } else {
                    self.errorMessage = "서버 오류가 발생했습니다"
                }
            case .unknown(let message):
                self.errorMessage = message
            }
        case .validation(let validationError):
            switch validationError {
            case .invalidFormat(let field):
                self.errorMessage = "\(field) 형식이 올바르지 않습니다"
            default:
                self.errorMessage = "입력값이 올바르지 않습니다"
            }
        case .business(let businessError):
            switch businessError {
            case .dataNotFound:
                self.errorMessage = "\(context) 데이터를 찾을 수 없습니다"
            case .operationNotAllowed:
                self.errorMessage = "권한이 없습니다"
            default:
                self.errorMessage = "\(context)를 불러올 수 없습니다"
            }
        case .unknown(let message):
            self.errorMessage = message.isEmpty ? "\(context) 로딩 중 오류가 발생했습니다" : message
        }
        
        print("❌ \(context) 실패: \(error)")
    }
} 