//
//  ArticleDetailViewModelResult.swift
//  Detail
//
//  Created by AI Assistant on 1/14/25.
//

import Domain
import Foundation
import Combine
import Shared

@MainActor
public final class ArticleDetailViewModelResult: ObservableObject {
    
    // MARK: - Dependencies
    private let id: String
    private let useCase: ArticleUseCaseResult
    
    // MARK: - Published Properties
    @Published public var detail: ArticleDetail?
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var isBookmarkLoading: Bool = false
    
    // MARK: - Initialization
    public init(id: String, useCase: ArticleUseCaseResult) {
        self.id = id
        self.useCase = useCase
    }
    
    // MARK: - Public Methods
    public func fetch() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.fetchArticleDetail(articleId: id)
        
        await result
            .onSuccess { [weak self] detail in
                await self?.handleFetchSuccess(detail)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "아티클 상세")
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func bookmark() async -> AppResult<Void> {
        guard let articleId = detail?.articleId else {
            return .failure(.validation(.emptyField("아티클 ID")))
        }
        
        await MainActor.run {
            isBookmarkLoading = true
        }
        
        let result = await useCase.toggleBookmarkStatus(articleId: "\(articleId)")
        
        await result
            .onSuccess { [weak self] _ in
                await self?.handleBookmarkSuccess()
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "북마크")
            }
        
        await MainActor.run {
            isBookmarkLoading = false
        }
        
        return result
    }
    
    public func refreshData() async {
        await fetch()
    }
    
    // MARK: - Private Methods
    @MainActor
    private func handleFetchSuccess(_ detail: ArticleDetail) async {
        self.detail = detail
        self.errorMessage = nil
    }
    
    @MainActor
    private func handleBookmarkSuccess() async {
        // 북마크 상태 토글
        self.detail?.isBookmarked.toggle()
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
                    self.errorMessage = "\(context)를 찾을 수 없습니다"
                } else {
                    self.errorMessage = "서버 오류가 발생했습니다"
                }
            case .unknown(let message):
                self.errorMessage = message
            }
        case .validation(let validationError):
            switch validationError {
            case .emptyField(let field):
                self.errorMessage = "\(field)이(가) 필요합니다"
            case .invalidFormat(let field):
                self.errorMessage = "\(field) 형식이 올바르지 않습니다"
            default:
                self.errorMessage = "입력값이 올바르지 않습니다"
            }
        case .business(let businessError):
            switch businessError {
            case .dataNotFound:
                self.errorMessage = "\(context)를 찾을 수 없습니다"
            case .operationNotAllowed:
                if context == "북마크" {
                    self.errorMessage = "북마크 권한이 없습니다"
                } else {
                    self.errorMessage = "권한이 없습니다"
                }
            default:
                self.errorMessage = "\(context) 작업을 수행할 수 없습니다"
            }
        case .unknown(let message):
            self.errorMessage = message.isEmpty ? "\(context) 처리 중 오류가 발생했습니다" : message
        }
        
        print("❌ \(context) 실패: \(error)")
    }
} 