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


protocol BookmarkViewModelBindable {
    
    func fetchUserInterests() async
    func fetchUserBookmarks() async
    
}



@MainActor
public class BookmarkViewModel: ObservableObject, BookmarkViewModelBindable {
    
    @Published public var interest: String = ""
    @Published public var interests: [Interest] = []
    
    @Published public var bookmarks: BookmarkedArticles? = nil
    
    private let useCase: ArticleUseCase
    
    public init(useCase: ArticleUseCase) {
        self.useCase = useCase
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
