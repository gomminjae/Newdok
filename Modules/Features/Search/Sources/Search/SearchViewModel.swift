//
//  SearchViewModel 2.swift
//  Search
//
//  Created by 권민재 on 7/13/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import SearchDomain
import Shared
import Observation

@Observable
@MainActor
public final class SearchViewModel: ErrorHandling {
    private let searchNewslettersUseCase: SearchNewslettersUseCase
    private let fetchPopularKeywordsUseCase: FetchPopularKeywordsUseCase

    public var searchText: String = ""
    public var searchResults: [SearchedNewsletter] = []
    public var isLoading: Bool = false
    public var searchError: AppError?
    public private(set) var popularKeywords: PopularKeywordList?
    public var isPopularLoading: Bool = false
    public var popularError: AppError?
    public var currentError: AppError?

    public init(
        searchNewslettersUseCase: SearchNewslettersUseCase,
        fetchPopularKeywordsUseCase: FetchPopularKeywordsUseCase
    ) {
        self.searchNewslettersUseCase = searchNewslettersUseCase
        self.fetchPopularKeywordsUseCase = fetchPopularKeywordsUseCase
    }

    public func clearSearchResults() {
        searchText = ""
        searchResults = []
        searchError = nil
    }

    public func loadPopularKeywords(force: Bool = false) async {
        if isPopularLoading { return }
        if !force, popularKeywords != nil { return }
        isPopularLoading = true
        popularError = nil
        do {
            let response = try await fetchPopularKeywordsUseCase.execute()
            self.popularKeywords = response
        } catch {
            handleError(error, feature: "search", operation: "loadPopularKeywords")
            self.popularError = currentError
        }
        isPopularLoading = false
    }

    public func searchNewsletters() async {
        guard !searchText.isEmpty else { return }
        guard !isLoading else { return }

        isLoading = true
        let query = searchText
        searchError = nil
        do {
            let results = try await searchNewslettersUseCase.execute(brandName: query)
            self.searchResults = results
        } catch {
            handleError(error, feature: "search", operation: "searchNewsletters")
            self.searchError = currentError
        }
        isLoading = false
    }

    public func selectPopularKeyword(_ keyword: String) async {
        searchText = keyword
        await searchNewsletters()
    }
}
