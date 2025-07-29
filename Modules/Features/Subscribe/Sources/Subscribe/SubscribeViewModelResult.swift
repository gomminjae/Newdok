//
//  SubscribeViewModelResult.swift
//  Subscribe
//
//  Created by AI Assistant on 1/14/25.
//

import SwiftUI
import Foundation
import Domain
import Shared

@MainActor
public class SubscribeViewModelResult: ObservableObject {
    
    // MARK: - Dependencies
    private let useCase: NewsletterUseCaseResult
    
    // MARK: - Published Properties
    @Published public var activeNewsletters: [Newsletter] = []
    @Published public var pausedNewsletters: [Newsletter] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var isSubscriptionLoading: Bool = false
    
    // MARK: - Initialization
    public init(useCase: NewsletterUseCaseResult) {
        self.useCase = useCase
    }
    
    // MARK: - Public Methods
    public func fetchActive() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.fetchActiveSubscription()
        
        await result
            .onSuccess { [weak self] newsletters in
                await self?.handleActiveSuccess(newsletters)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "활성 구독")
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func fetchPaused() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.fetchPausedSubscription()
        
        await result
            .onSuccess { [weak self] newsletters in
                await self?.handlePausedSuccess(newsletters)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "일시정지 구독")
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func pause(newsletterId: String) async -> AppResult<Void> {
        await MainActor.run {
            isSubscriptionLoading = true
        }
        
        let result = await useCase.pauseSubscription(newsletterId: newsletterId)
        
        await result
            .onSuccess { [weak self] _ in
                await self?.handlePauseSuccess(newsletterId: newsletterId)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "구독 일시정지")
            }
        
        await MainActor.run {
            isSubscriptionLoading = false
        }
        
        return result
    }
    
    public func resume(newsletterId: String) async -> AppResult<Void> {
        await MainActor.run {
            isSubscriptionLoading = true
        }
        
        let result = await useCase.resumeSubscription(newsletterId: newsletterId)
        
        await result
            .onSuccess { [weak self] _ in
                await self?.handleResumeSuccess(newsletterId: newsletterId)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "구독 재시작")
            }
        
        await MainActor.run {
            isSubscriptionLoading = false
        }
        
        return result
    }
    
    public func refreshData() async {
        await fetchActive()
        await fetchPaused()
    }
    
    public func loadInitialData() async {
        await refreshData()
    }
    
    // MARK: - Private Methods
    @MainActor
    private func handleActiveSuccess(_ newsletters: [Newsletter]) async {
        self.activeNewsletters = newsletters
    }
    
    @MainActor
    private func handlePausedSuccess(_ newsletters: [Newsletter]) async {
        self.pausedNewsletters = newsletters
    }
    
    @MainActor
    private func handlePauseSuccess(newsletterId: String) async {
        // 활성 목록에서 제거하고 일시정지 목록으로 이동
        if let index = activeNewsletters.firstIndex(where: { $0.id == newsletterId }) {
            let newsletter = activeNewsletters.remove(at: index)
            pausedNewsletters.append(newsletter)
        }
    }
    
    @MainActor
    private func handleResumeSuccess(newsletterId: String) async {
        // 일시정지 목록에서 제거하고 활성 목록으로 이동
        if let index = pausedNewsletters.firstIndex(where: { $0.id == newsletterId }) {
            let newsletter = pausedNewsletters.remove(at: index)
            activeNewsletters.append(newsletter)
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
                self.errorMessage = "\(context) 데이터가 없습니다"
            case .operationNotAllowed:
                if context.contains("구독") {
                    self.errorMessage = "구독 상태를 변경할 수 없습니다"
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