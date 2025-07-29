//
//  ExploreViewModelResult.swift
//  Explore
//
//  Created by AI Assistant on 1/14/25.
//

import Combine
import Shared
import Domain
import SwiftUI

@MainActor
public class ExploreViewModelResult: ObservableObject {
    
    // MARK: - Dependencies
    private let useCase: NewsletterUseCaseResult
    
    // MARK: - Published Properties
    @Published public var myRecommendation: [NewsletterDetail] = []
    @Published public var unionRecommendation: [NewsletterDetail] = []
    @Published public var fixedMyRecommendation: [NewsletterDetail] = []
    @Published public var fixedUnionRecommendation: [NewsletterDetail] = []
    @Published public var allNewsletters: [Brand] = []
    
    // 현재 선택된 탭 (0: 추천, 1: 전체)
    @Published public var selectedTab: Int = 0
    
    // 필터 옵션
    @Published public var orderOpt: String? = "인기순"
    @Published public var industry: [Int]? = nil
    @Published public var day: [Int]? = nil
    
    // UI 상태
    @Published public var isShowFilterSheet: Bool = false
    @Published public var isShowSortSheet: Bool = false
    @Published public var isRecommend: Bool = false
    @Published public var shouldScrollToTop: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    // MARK: - Computed Properties
    var hasUserProfile: Bool {
        return UserInfoStore.shared.hasProfile
    }
    
    // MARK: - Initialization
    public init(useCase: NewsletterUseCaseResult) {
        self.useCase = useCase
    }
    
    // MARK: - Public Methods
    public func fetchRecommendation() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.fetchRecommendation()
        
        await result
            .onSuccess { [weak self] recommendation in
                await self?.handleRecommendationSuccess(recommendation)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "추천 뉴스레터")
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func fetchAllNewsletters() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.fetchNewsletters(
            orderOpt: orderOpt,
            industry: industry,
            day: day
        )
        
        await result
            .onSuccess { [weak self] newsletters in
                await self?.handleNewslettersSuccess(newsletters)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "전체 뉴스레터")
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func fetchGuestNewsletters() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let result = await useCase.fetchGuestNewsletters(
            orderOpt: orderOpt,
            industry: industry,
            day: day
        )
        
        await result
            .onSuccess { [weak self] newsletters in
                await self?.handleNewslettersSuccess(newsletters)
            }
            .onFailure { [weak self] error in
                await self?.handleError(error, context: "비회원 뉴스레터")
            }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    public func fetchBrandDetail(id: String) async -> AppResult<BrandDetail> {
        return await useCase.fetchNewsletterBrand(id: id)
    }
    
    public func applyFilters() async {
        shouldScrollToTop = true
        
        if hasUserProfile {
            await fetchAllNewsletters()
        } else {
            await fetchGuestNewsletters()
        }
        
        // 스크롤 상태 리셋
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.shouldScrollToTop = false
        }
    }
    
    public func refreshData() async {
        if selectedTab == 0 {
            await fetchRecommendation()
        } else {
            await applyFilters()
        }
    }
    
    // MARK: - Private Methods
    @MainActor
    private func handleRecommendationSuccess(_ recommendation: RecommendedNewsletter) async {
        self.myRecommendation = recommendation.intersection
        self.unionRecommendation = recommendation.union
        self.fixedMyRecommendation = Array(recommendation.intersection.prefix(5))
        self.fixedUnionRecommendation = Array(recommendation.union.prefix(6))
        self.isRecommend = true
    }
    
    @MainActor
    private func handleNewslettersSuccess(_ newsletters: [Brand]) async {
        self.allNewsletters = newsletters
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
            case .invalidFormat(let field):
                self.errorMessage = "\(field) 형식이 올바르지 않습니다"
            default:
                self.errorMessage = "필터 설정이 올바르지 않습니다"
            }
        case .business(let businessError):
            switch businessError {
            case .dataNotFound:
                self.errorMessage = "\(context)가 없습니다"
            case .operationNotAllowed:
                self.errorMessage = "권한이 없습니다"
            default:
                self.errorMessage = "\(context)를 불러올 수 없습니다"
            }
        case .unknown(let message):
            self.errorMessage = message.isEmpty ? "\(context) 로딩 중 오류가 발생했습니다" : message
        }
        
        // 추천 관련 특별 처리
        if context == "추천 뉴스레터" {
            self.isRecommend = false
        }
        
        print("❌ \(context) 실패: \(error)")
    }
} 