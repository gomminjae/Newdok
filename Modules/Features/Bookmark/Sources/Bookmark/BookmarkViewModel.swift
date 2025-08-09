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
import Combine
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
    private var cancellables = Set<AnyCancellable>()
    
    public init(useCase: ArticleUseCase) {
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

    func fetchUserInterests() async  {
        do {
            let response = try await useCase.fetchBookmarkedInterests()
            interests = response
        } catch {
            print("관심사 불러오기 실패: \(error)")
        }
    }
    
    func fetchUserBookmarks() async {
        do {
            let sortBy = convertSortOrderToOption(sortOrder)
            let response = try await useCase.fetchBookmarkedArticles(interest: interest, sortBy: sortBy)
            bookmarks = response
        } catch {
            print("북마크 불러오기 실패: \(error)")
        }
    }

    // 최초 로드: 관심사/목록 병렬 + 스켈레톤 표시용 플래그
    @Published public var isLoading: Bool = false
    func loadInitial() {
        cancelLoads()
        loadTask = Task { @MainActor in
            isLoading = true
            async let interests = useCase.fetchBookmarkedInterests()
            async let articles = useCase.fetchBookmarkedArticles(interest: interest, sortBy: convertSortOrderToOption(sortOrder))
            do {
                self.interests = try await interests
                self.bookmarks = try await articles
            } catch {
                print("초기 로드 실패: \(error)")
            }
            isLoading = false
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
