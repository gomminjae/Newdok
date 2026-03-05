//
//  SearchViewModel 2.swift
//  Search
//
//  Created by 권민재 on 7/13/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import Domain
import Shared

@MainActor
public final class SearchViewModel: ObservableObject, ErrorHandling {
    private let useCase: SearchUseCase

    @Published public var searchText: String = ""
    @Published public var searchResults: [SearchedNewsletter] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public private(set) var popularKeywords: PopularKeywordList?
    @Published public var isPopularLoading: Bool = false
    @Published public var popularErrorMessage: String?
    @Published public var currentError: AppError?

    public init(useCase: SearchUseCase) {
        self.useCase = useCase
    }

    public func clearSearchResults() {
        searchText = ""
        searchResults = []
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
        } catch {
            handleError(error, feature: "search", operation: "loadPopularKeywords")
            self.popularErrorMessage = currentError?.userFacingMessage
        }
        isPopularLoading = false
    }

    public func searchNewsletters() async {
        guard !searchText.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        do {
            let results = try await useCase.searchNewsletters(brandName: searchText)
            self.searchResults = results
        } catch {
            handleError(error, feature: "search", operation: "searchNewsletters")
            self.errorMessage = currentError?.userFacingMessage
        }
        isLoading = false
    }

    public func selectPopularKeyword(_ keyword: String) async {
        searchText = keyword
        await searchNewsletters()
    }
}
