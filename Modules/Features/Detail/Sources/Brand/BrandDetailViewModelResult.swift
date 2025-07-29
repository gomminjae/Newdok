//
//  BrandDetailViewModelResult.swift
//  Detail
//
//  Created by AI Assistant on 1/14/25.
//

import Domain
import Foundation
import Combine
import Shared

@MainActor
public final class BrandDetailViewModelResult: ObservableObject {
    
    // MARK: - Dependencies
    private let id: String
    private let newsletterUseCase: NewsletterUseCaseResult
    private let articleUseCase: ArticleUseCaseResult
    
    // MARK: - Published Properties
    @Published public var detail: BrandDetail?
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var isSubscriptionLoading: Bool = false
    @Published public var isBookmarkLoading: Bool = false
    
    // MARK: - Initialization
    public init(id: String, newsletterUseCase: NewsletterUseCaseResult, articleUseCase: ArticleUseCaseResult) {
        self.id = id
        self.newsletterUseCase = newsletterUseCase
        self.articleUseCase = articleUseCase
    }
    
    // MARK: - Public Methods
    public func fetch() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await newsletterUseCase.fetchNewsletterBrand(id: id)
        
        await result
            .onSuccess { [weak self] detail in
                await self?.handleFetchSuccess(detail)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "브랜드 상세")
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func guestFetch() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await newsletterUseCase.fetchGuestNewsletterBrand(id: id)
        
        await result
            .onSuccess { [weak self] detail in
                await self?.handleFetchSuccess(detail)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "비회원 브랜드 상세")
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func resume() async -> AppResult<Void> {
        await MainActor.run {
            isSubscriptionLoading = true
        }
        
        let result = await newsletterUseCase.resumeSubscription(newsletterId: id)
        
        await result
            .onSuccess { [weak self] _ in
                await self?.handleSubscriptionChange(isPaused: false)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "구독 재시작")
            }
        
        await MainActor.run {
            isSubscriptionLoading = false
        }
        
        return result
    }
    
    public func pause() async -> AppResult<Void> {
        await MainActor.run {
            isSubscriptionLoading = true
        }
        
        let result = await newsletterUseCase.pauseSubscription(newsletterId: id)
        
        await result
            .onSuccess { [weak self] _ in
                await self?.handleSubscriptionChange(isPaused: true)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "구독 일시정지")
            }
        
        await MainActor.run {
            isSubscriptionLoading = false
        }
        
        return result
    }
    
    public func toggleBookmark(articleId: String) async -> AppResult<Void> {
        await MainActor.run {
            isBookmarkLoading = true
        }
        
        let result = await articleUseCase.toggleBookmarkStatus(articleId: articleId)
        
        await result
            .onSuccess { [weak self] _ in
                await self?.handleBookmarkToggle(articleId: articleId)
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
    private func handleFetchSuccess(_ detail: BrandDetail) async {
        self.detail = detail
        self.errorMessage = nil
    }
    
    @MainActor
    private func handleSubscriptionChange(isPaused: Bool) async {
        self.detail?.isPaused = isPaused
    }
    
    @MainActor
    private func handleBookmarkToggle(articleId: String) async {
        // 해당 아티클의 북마크 상태 토글
        if let index = detail?.brandArticleList.firstIndex(where: { "\($0.id)" == articleId }) {
            detail?.brandArticleList[index].isBookmarked.toggle()
        }
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
                    self.errorMessage = "\(context) 정보를 찾을 수 없습니다"
                } else if statusCode == 403 {
                    self.errorMessage = "권한이 없습니다"
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
                self.errorMessage = "\(context) 정보를 찾을 수 없습니다"
            case .operationNotAllowed:
                if context.contains("구독") {
                    self.errorMessage = "구독 상태를 변경할 수 없습니다"
                } else if context == "북마크" {
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