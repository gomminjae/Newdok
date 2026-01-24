//
//  SearchViewModel 2.swift
//  Search
//
//  Created by 권민재 on 7/13/25.
//  Copyright © 2025 Newdok. All rights reserved.
//


import Foundation
import Domain
import Core

@MainActor
public final class SearchViewModel: ObservableObject {
    private let useCase: SearchUseCase
    
    @Published public var searchText: String = ""
    @Published public var searchResults: [SearchedNewsletter] = []
    @Published public var bookmarkResults: [Bookmark] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public private(set) var popularKeywords: PopularKeywordList?
    @Published public var isPopularLoading: Bool = false
    @Published public var popularErrorMessage: String?
    
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
    
    public func loadPopularKeywords(force: Bool = false) async {
        if isPopularLoading { return }
        if !force, popularKeywords != nil { return }
        isPopularLoading = true
        popularErrorMessage = nil
        do {
            let response = try await useCase.fetchPopularKeywords()
            self.popularKeywords = response
            logDebug("인기 검색어 조회 완료 - \(response.keywords.count)개", category: .search)
        } catch {
            logError("인기 검색어 조회 실패: \(error.localizedDescription)", category: .search)
            self.popularErrorMessage = error.localizedDescription
        }
        isPopularLoading = false
    }
    
    public func searchNewsletters() async {
        guard !searchText.isEmpty else { return }
        logInfo("뉴스레터 검색 시작: \"\(searchText)\"", category: .search)
        isLoading = true
        errorMessage = nil
        do {
            let results = try await useCase.searchNewsletters(brandName: searchText)
            self.searchResults = results
            logDebug("뉴스레터 검색 완료 - \(results.count)개 결과", category: .search)
        } catch {
            logError("뉴스레터 검색 실패: \(error.localizedDescription)", category: .search)
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func searchArticles() async {
        guard !searchText.isEmpty else { return }
        logInfo("아티클 검색 시작: \"\(searchText)\"", category: .search)
        isLoading = true
        errorMessage = nil
        do {
            let results = try await useCase.searchArticles(keyword: searchText)
            self.bookmarkResults = results
            logDebug("아티클 검색 완료 - \(results.count)개 결과", category: .search)
        } catch {
            logError("아티클 검색 실패: \(error.localizedDescription)", category: .search)
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    public func selectPopularKeyword(_ keyword: String) async {
        searchText = keyword
        await searchNewsletters()
    }
} 
