//
//  ExploreViewResult.swift
//  Explore
//
//  Created by AI Assistant on 1/14/25.
//

import SwiftUI
import DesignSystem
import Domain
import Shared
import Lottie 
import Combine

public struct ExploreViewResult: View {
    
    @StateObject private var viewModel: ExploreViewModelResult
    @State private var currentPage: Int = 0
    @State private var isLoaded: Bool = false
    @State private var userInfo: UserInfo?
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var exploreIntent: ExploreIntent
    
    @AppStorage("isGuest") private var isGuest: Bool = false
    
    private var nickname: String {
        return userInfo?.nickname ?? ""
    }

    public init(viewModel: ExploreViewModelResult) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                tabSwitcher
                Divider()
                
                if isGuest {
                    Group {
                        if viewModel.selectedTab == 0 {
                            allNewsletterSection
                        } else {
                            guestSection
                        }
                    }
                } else {
                    Group {
                        if viewModel.selectedTab == 0 {
                            if viewModel.isLoading {
                                loadingView
                            } else if !viewModel.hasUserProfile {
                                noProfileSection
                            } else {
                                ScrollView(showsIndicators: false) {
                                    recommendationSection
                                }
                                .background(Color(hex: "#F5F5F7"))
                            }
                        } else if viewModel.selectedTab == 1 {
                            allNewsletterSection
                                .background(Color(hex: "#F5F5F7"))
                        }
                    }
                    .padding(.bottom, 0)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.white)
            .onChange(of: isGuest) {
                viewModel.resetFilters()
                // 게스트 상태 변경 시 UserInfo 업데이트
                userInfo = UserInfoStore.shared.load()
            }
            .onChange(of: exploreIntent.trigger) { _ in
                if let day = exploreIntent.day, viewModel.day != [day] {
                    viewModel.day = [day]
                    viewModel.selectedTab = 1
                    Task { await viewModel.applyFilters() }
                }
                if let industry = exploreIntent.industry, viewModel.industry != [industry] {
                    viewModel.industry = [industry]
                    viewModel.selectedTab = 1
                    Task { await viewModel.applyFilters() }
                }
            }
            .onAppear {
                userInfo = UserInfoStore.shared.load()
                if !isGuest && !isLoaded {
                    Task {
                        await viewModel.fetchRecommendation()
                        await viewModel.fetchAllNewsletters()
                        isLoaded = true
                    }
                }
            }
            .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("확인") {
                    // 에러 메시지는 자동으로 초기화됨
                }
                Button("다시 시도") {
                    Task {
                        if viewModel.selectedTab == 0 {
                            await viewModel.fetchRecommendation()
                        } else {
                            await viewModel.fetchAllNewsletters()
                        }
                    }
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            if !isGuest {
                Text("\(nickname)님의")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "565656"))
                +
                Text(" 맞춤 큐레이션")
                    .font(.hanSansNeo(14, .bold))
                    .foregroundStyle(Color(hex: "565656"))
            } else {
                Text("둘러보기")
                    .font(.hanSansNeo(20, .bold))
                    .foregroundStyle(Color(hex: "161616"))
            }
            
            Spacer()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryNormal))
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            if !isGuest {
                TabButton(
                    title: "추천",
                    isSelected: viewModel.selectedTab == 0,
                    action: { 
                        viewModel.selectedTab = 0
                        if !isLoaded {
                            Task { await viewModel.fetchRecommendation() }
                        }
                    }
                )
            }
            
            TabButton(
                title: isGuest ? "전체 뉴스레터" : "모든 뉴스레터",
                isSelected: isGuest ? true : viewModel.selectedTab == 1,
                action: { 
                    if !isGuest {
                        viewModel.selectedTab = 1
                        Task { await viewModel.fetchAllNewsletters() }
                    }
                }
            )
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryNormal))
                .scaleEffect(1.2)
            
            Text("맞춤 뉴스레터를 찾고 있습니다...")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "565656"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#F5F5F7"))
    }
    
    private var recommendationSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.myRecommendation, id: \.newsletterId) { newsletter in
                RecommendationCard(newsletter: newsletter) {
                    router.push(.brandDetail(id: String(newsletter.newsletterId)))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var allNewsletterSection: some View {
        VStack(spacing: 0) {
            filterSection
            
            if viewModel.isLoading {
                loadingView
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.allNewsletters, id: \.brandId) { brand in
                            BrandCard(brand: brand) {
                                router.push(.brandDetail(id: String(brand.brandId)))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .background(Color(hex: "#F5F5F7"))
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("요일")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "161616"))
                
                Spacer()
                
                Button("초기화") {
                    viewModel.resetFilters()
                    Task { await viewModel.applyFilters() }
                }
                .font(.hanSansNeo(12, .medium))
                .foregroundColor(Color(hex: "565656"))
            }
            
            // 요일 필터
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(dayOptions, id: \.value) { option in
                        FilterChip(
                            title: option.text,
                            isSelected: viewModel.day?.contains(option.value) ?? false
                        ) {
                            viewModel.toggleDayFilter(option.value)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // 산업군 필터
            Text("산업군")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "161616"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(industryOptions, id: \.value) { option in
                        FilterChip(
                            title: option.text,
                            isSelected: viewModel.industry?.contains(option.value) ?? false
                        ) {
                            viewModel.toggleIndustryFilter(option.value)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // 적용 버튼
            Button("필터 적용") {
                Task { await viewModel.applyFilters() }
            }
            .font(.hanSansNeo(14, .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.primaryNormal)
            .cornerRadius(6)
            .padding(.horizontal, 20)
            .disabled(viewModel.isLoading)
        }
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    private var noProfileSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "CCCCCC"))
            
            Text("프로필을 완성해주세요")
                .font(.hanSansNeo(16, .medium))
                .foregroundStyle(Color(hex: "161616"))
            
            Text("관심사와 산업군을 설정하면\n맞춤 뉴스레터를 추천해드립니다")
                .font(.hanSansNeo(14, .regular))
                .foregroundStyle(Color(hex: "565656"))
                .multilineTextAlignment(.center)
            
            Button("프로필 설정하기") {
                router.resetTo(.tabbar(selectedTab: .mypage))
            }
            .font(.hanSansNeo(14, .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.primaryNormal)
            .cornerRadius(6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#F5F5F7"))
    }
    
    private var guestSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "envelope")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "CCCCCC"))
            
            Text("로그인이 필요한 기능입니다")
                .font(.hanSansNeo(16, .medium))
                .foregroundStyle(Color(hex: "161616"))
            
            Text("로그인하고 맞춤 뉴스레터를\n추천받아보세요")
                .font(.hanSansNeo(14, .regular))
                .foregroundStyle(Color(hex: "565656"))
                .multilineTextAlignment(.center)
            
            Button("로그인") {
                router.push(.login)
            }
            .font(.hanSansNeo(14, .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.primaryNormal)
            .cornerRadius(6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#F5F5F7"))
    }
    
    // MARK: - Filter Options
    private let dayOptions: [(text: String, value: Int)] = [
        ("월", 1), ("화", 2), ("수", 3), ("목", 4), ("금", 5), ("토", 6), ("일", 7)
    ]
    
    private let industryOptions: [(text: String, value: Int)] = [
        ("IT/테크", 1), ("비즈니스", 2), ("경제/금융", 3), ("라이프스타일", 4),
        ("문화/예술", 5), ("건강/의료", 6), ("교육", 7), ("여행", 8)
    ]
}

// MARK: - Supporting Views
private struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.hanSansNeo(14, isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? Color(hex: "161616") : Color(hex: "999999"))
                .padding(.bottom, 8)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(isSelected ? Color.primaryNormal : Color.clear),
                    alignment: .bottom
                )
        }
        .padding(.trailing, 24)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.hanSansNeo(12, .medium))
                .foregroundColor(isSelected ? .white : Color(hex: "565656"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.primaryNormal : Color(hex: "F5F5F5"))
                .cornerRadius(16)
        }
    }
}

private struct RecommendationCard: View {
    let newsletter: NewsletterDetail
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(newsletter.brandName)
                        .font(.hanSansNeo(16, .bold))
                        .foregroundStyle(Color(hex: "161616"))
                    
                    Spacer()
                    
                    Text("매주 \(dayText)")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundStyle(Color(hex: "2866D3"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "E8F1FF"))
                        .cornerRadius(12)
                }
                
                Text(newsletter.introduction)
                    .font(.hanSansNeo(14, .regular))
                    .foregroundStyle(Color(hex: "565656"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    ForEach(newsletter.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.hanSansNeo(11, .medium))
                            .foregroundStyle(Color(hex: "999999"))
                    }
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dayText: String {
        let days = ["", "월", "화", "수", "목", "금", "토", "일"]
        return newsletter.deliveryDays.compactMap { days[safe: $0] }.joined(separator: ", ")
    }
}

private struct BrandCard: View {
    let brand: Brand
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(brand.brandName)
                        .font(.hanSansNeo(16, .bold))
                        .foregroundStyle(Color(hex: "161616"))
                    
                    Spacer()
                    
                    if !brand.deliveryDays.isEmpty {
                        Text(dayText)
                            .font(.hanSansNeo(12, .medium))
                            .foregroundStyle(Color(hex: "2866D3"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "E8F1FF"))
                            .cornerRadius(12)
                    }
                }
                
                Text(brand.introduction)
                    .font(.hanSansNeo(14, .regular))
                    .foregroundStyle(Color(hex: "565656"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("구독자 \(brand.subscriberCount)명")
                        .font(.hanSansNeo(11, .medium))
                        .foregroundStyle(Color(hex: "999999"))
                    
                    Spacer()
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dayText: String {
        let days = ["", "월", "화", "수", "목", "금", "토", "일"]
        return brand.deliveryDays.compactMap { days[safe: $0] }.joined(separator: ", ")
    }
}

// MARK: - Array Extension
private extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 