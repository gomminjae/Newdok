//
//  ArticleDetailViewModel.swift
//  Detail
//
//  Created by 권민재 on 5/12/25.
//

import Domain
import Foundation
import Combine



@MainActor
public final class ArticleDetailViewModel: ObservableObject {
    
    @Published var detail: ArticleDetail?
    @Published var isLoading: Bool = false
    
    private let id: String
    private let useCase: ArticleUseCase
    
    public init(id: String, useCase: ArticleUseCase) {
        self.id = id
        self.useCase = useCase
    }
    
    
    public func fetch() async {
        do {
            let data = try await useCase.fetchArticleDetail(articleId: id)
            detail = data
        } catch {
        }
    }
    
    public func bookmark() async {
        do {
            guard let articleId = detail?.articleId else { return }
            _ = try await useCase.toggleBookmarkStatus(articleId: "\(articleId)")
            detail?.isBookmarked.toggle()
        } catch {
        }
    }
    
}
