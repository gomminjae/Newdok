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

    private var searchGeneration = 0

    public init(
        searchNewslettersUseCase: SearchNewslettersUseCase,
        fetchPopularKeywordsUseCase: FetchPopularKeywordsUseCase
    ) {
        self.searchNewslettersUseCase = searchNewslettersUseCase
        self.fetchPopularKeywordsUseCase = fetchPopularKeywordsUseCase
    }

    public func clearSearchResults() {
        searchGeneration += 1
        searchText = ""
        searchResults = []
        searchError = nil
        isLoading = false
    }

    public func loadPopularKeywords(force: Bool = false) async {
        if isPopularLoading { return }
        if !force, popularKeywords != nil { return }
        isPopularLoading = true
        defer { isPopularLoading = false }
        popularError = nil
        do {
            let response = try await fetchPopularKeywordsUseCase.execute()
            self.popularKeywords = response
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            handleError(error, feature: "search", operation: "loadPopularKeywords")
            self.popularError = currentError
        }
    }

    public func searchNewsletters() async {
        guard !searchText.isEmpty else { return }

        searchGeneration += 1
        let generation = searchGeneration
        isLoading = true
        defer {
            if generation == searchGeneration {
                isLoading = false
            }
        }

        let query = searchText
        searchError = nil
        do {
            let results = try await searchNewslettersUseCase.execute(brandName: query)
            guard generation == searchGeneration, !Task.isCancelled else { return }
            self.searchResults = results
        } catch is CancellationError {
            return
        } catch {
            guard generation == searchGeneration, !Task.isCancelled else { return }
            handleError(error, feature: "search", operation: "searchNewsletters")
            self.searchError = currentError
        }
    }

    public func selectPopularKeyword(_ keyword: String) async {
        searchText = keyword
        await searchNewsletters()
    }
}
