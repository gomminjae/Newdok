//
//  Explore ViewModel.swift
//  Explore
//
//  Created by 권민재 on 4/24/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import Combine
import Shared
import Domain
import SwiftUI
import Shared


@MainActor
public class ExploreViewModel: ObservableObject {
    
    @Published public var myRecommendation: [NewsletterDetail] = []
    @Published public var unionRecommendation: [NewsletterDetail] = []
    @Published public var fixedMyRecommendation: [NewsletterDetail] = []
    @Published public var fixedUnionRecommendation: [NewsletterDetail] = []

    @Published public var allNewsletters: [Brand] = []

    // 현재 선택된 탭 (0: 추천, 1: 전체)
    @Published public var selectedTab: Int = 0
    
    @Published public var orderOpt: String? = "인기순"
    @Published public var industry: [Int]? = nil
    @Published public var day: [Int]? = nil
    
    
    
    
    @Published public var isShowFilterSheet: Bool = false
    @Published public var isShowSortSheet: Bool = false
    @Published public var isRecommend: Bool = false
    
    var hasUserProfile: Bool {
        return UserInfoStore.shared.hasProfile
    }
    
    
    private let useCase: NewsletterUseCase
    
    public init(useCase: NewsletterUseCase) {
        self.useCase = useCase
    }
    
    
    
    
    
    
    public func fetchRecommendation() async {
        Task {
            do {
                let response = try await useCase.fetchRecommendation()
                
                myRecommendation = response.intersection
                unionRecommendation = response.union
                fixedMyRecommendation = Array(response.intersection.prefix(5))
                fixedUnionRecommendation = Array(response.union.prefix(6))
            } catch {
                print("추천 에러")
                isRecommend = false
            }
        }
    }
    
    public func fetchAllNewsletters() async {
        Task {
            do {
                let response = try await useCase.fetchNewsletters(orderOpt: orderOpt, industry: industry, day: day)
                allNewsletters = response
                
            } catch {
                print("모든 뉴스레터 에러",error)
            }
        }
    }
    
    public func fetchBrandDetail(id: String) async {
        Task {
            do {
                _ = try await useCase.fetchNewsletterBrand(id: id)
                
            }
        }
    }
    
    public func fetchGuestAllNewsletters() async {
        do {
            let response = try await useCase.fetchGuestNewsletters(orderOpt: orderOpt, industry: industry, day: day)
            allNewsletters = response
        } catch {
            print("비회원 조회 실패")
        }
    }
    
    
    
    
}
