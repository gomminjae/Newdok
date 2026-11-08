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
    public let analytics: AnalyticsClient

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

    public private(set) var analyticsList = AnalyticsListContext(.searchNewsletters)
    public private(set) var hasSearched = false
    public var querySource: AnalyticsQuerySource = .typed
    var analyticsState: AnalyticsContentState? {
        guard !isLoading else { return nil }
        if searchError != nil { return .failed }
        guard hasSearched else { return nil }
        return searchResults.isEmpty ? .noResults : .ready
    }
    private var latestRequest: AnalyticsListContext?
    var analyticsStateList: AnalyticsListContext {
        searchError == nil ? analyticsList : latestRequest ?? analyticsList
    }
    private var searchGeneration = 0

    public init(
        searchNewslettersUseCase: SearchNewslettersUseCase,
        fetchPopularKeywordsUseCase: FetchPopularKeywordsUseCase,
        analytics: AnalyticsClient = .disabled
    ) {
        self.analytics = analytics
        self.searchNewslettersUseCase = searchNewslettersUseCase
        self.fetchPopularKeywordsUseCase = fetchPopularKeywordsUseCase
    }

    public func clearSearchResults() {
        searchGeneration += 1
        hasSearched = false
        latestRequest = nil
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
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !Task.isCancelled else { return }

        searchGeneration += 1
        let generation = searchGeneration
        let context = AnalyticsListContext(.searchNewsletters)
        let source = querySource
        latestRequest = context
        analytics.record(.searchStarted(list: context, source: source), from: .search)
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
            analyticsList = context
            hasSearched = true
            analytics.record(.searchFinished(list: context, source: source, hasResults: !results.isEmpty), from: .search)
        } catch is CancellationError {
            return
        } catch {
            guard generation == searchGeneration, !Task.isCancelled else { return }
            handleError(error, feature: "search", operation: "searchNewsletters")
            self.searchError = currentError
            analytics.record(.operationFailed(.list(context), category: .init(error: error)), from: .search)
        }
    }

    public func selectPopularKeyword(_ keyword: String) async {
        querySource = .popularKeyword
        searchText = keyword
        await searchNewsletters()
    }
}
