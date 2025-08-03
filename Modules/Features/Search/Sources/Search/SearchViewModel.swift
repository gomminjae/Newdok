//
//  SearchViewModel 2.swift
//  Search
//
//  Created by 권민재 on 7/13/25.
//  Copyright © 2025 Newdok. All rights reserved.
//


import Foundation
import Domain

@MainActor
public final class SearchViewModel: ObservableObject {
    private let useCase: SearchUseCase
    
    @Published public var searchText: String = ""
    @Published public var searchResults: [SearchedNewsletter] = []
    @Published public var bookmarkResults: [Bookmark] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    public init(useCase: SearchUseCase) {
        self.useCase = useCase
        setupTokenObserver()
    }
    
    private func setupTokenObserver() {
        // 토큰 상태 변화 감지
        NotificationCenter.default.addObserver(
            forName: .didReceiveUnauthorized,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearSearchResults()
        }
        
        // 로그인 성공 감지
        NotificationCenter.default.addObserver(
            forName: .didLoginSuccess,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearSearchResults()
        }
    }
    
    public func clearSearchResults() {
        searchText = ""
        searchResults = []
        bookmarkResults = []
        errorMessage = nil
    }
    
    public func searchNewsletters() async {
        guard !searchText.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            let results = try await useCase.searchNewsletters(brandName: searchText)
            self.searchResults = results
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func searchArticles() async {
        guard !searchText.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        do {
            let results = try await useCase.searchArticles(keyword: searchText)
            self.bookmarkResults = results
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
} 