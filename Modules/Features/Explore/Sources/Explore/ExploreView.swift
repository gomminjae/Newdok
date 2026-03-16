//
//  ExploreView.swift
//  Newdok
//
//  Created by 권민재 on 2/23/25.
//
import SwiftUI
import DesignSystem
import Domain
import Shared

import Combine

public struct ExploreView: View {
    @StateObject private var viewModel: ExploreViewModel
    @State private var currentPage: Int = 0
    @State private var recommendationSpinAngle: Double = 0
    @State private var filterSpinAngle: Double = 0
    @State private var isLoaded: Bool = false
    @State private var userInfo: UserInfo?
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var exploreIntent: ExploreIntent
    
    @AppStorage("isGuest") private var isGuest: Bool = false
    
    private var nickname: String {
        return userInfo?.nickname ?? ""
    }

    public init(viewModel: ExploreViewModel) {
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
                            if !isLoaded {
                                EmptyView() // 후에 로딩뷰
                            } else if !viewModel.hasUserProfile {
                                noProfileSection
                            } else {
                                ScrollView(showsIndicators: false) {
                                    recommendationSection
                                }
                                .background(Color.bgSystem)
                            }
                        } else if viewModel.selectedTab == 1 {
                            allNewsletterSection
                                .background(Color.bgSystem)
                        }
                    }
                    .padding(.bottom, 0)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.white)
            .onChange(of: isGuest) {
                viewModel.day = nil
                viewModel.industry = nil
                viewModel.orderOpt = "인기순"
                // 게스트 상태 변경 시 UserInfo 업데이트
                userInfo = UserInfoStore.shared.load()
            }
            .onChange(of: exploreIntent.trigger) {
                // 모든 설정을 한 번에 처리
                var newDay: Int?
                var newTab: Int?
                
                if let day = exploreIntent.day, viewModel.day != [day] {
                    newDay = day
                    exploreIntent.day = nil
                }
                
                if let tab = exploreIntent.selectedTab, viewModel.selectedTab != tab {
                    newTab = tab
                    exploreIntent.selectedTab = nil
                }
                
                // 데이터 로딩 후 UI 업데이트
                Task {
                    if let day = newDay {
                        viewModel.day = [day]
                    }
                    if let tab = newTab {
                        viewModel.selectedTab = tab
                    }
                    
                    if isGuest {
                        await viewModel.fetchGuestAllNewsletters()
                    } else {
                        await viewModel.fetchRecommendation()
                        if viewModel.selectedTab == 1 {
                            await viewModel.fetchAllNewsletters()
                        } else {
                            Task {
                                await viewModel.fetchAllNewsletters()
                            }
                        }
                    }
                }
            }
            .onAppear {
                // UserInfo 로드
                userInfo = UserInfoStore.shared.load()
                
                Task {
                    if isGuest {
                        await viewModel.fetchGuestAllNewsletters()
                        isLoaded = true
                    } else {
                        await viewModel.fetchRecommendation()
                        isLoaded = true
                        Task {
                            await viewModel.fetchAllNewsletters()
                        }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // 앱이 포그라운드로 올 때 UserInfo 업데이트
                userInfo = UserInfoStore.shared.load()
            }
            .serverErrorPopup(
                error: $viewModel.currentError,
                onRetry: {
                    Task {
                        if isGuest {
                            await viewModel.fetchGuestAllNewsletters()
                        } else {
                            await viewModel.fetchRecommendation()
                            await viewModel.fetchAllNewsletters()
                        }
                    }
                }
            )
        }
    }

    // MARK: - 헤더
    private var headerView: some View {
        HStack {
            Text("둘러보기")
                .font(.hanSansNeo(18, .bold))
                .foregroundStyle(Color.captionHeavy)
            Spacer()
            Button {
                router.push(.search)
            } label: {
                Image(asset: DesignSystemAsset.lineSearch)
                    .padding(.trailing, 12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 17)
        .background(Color.white)
    }

    // MARK: - 탭 스위처
    private var tabSwitcher: some View {
        VStack(spacing: 0) {
            if isGuest {
                HStack(spacing: 0) {
                    tabButton(title: "모든 뉴스레터", index: 0)
                    tabButton(title: "추천 뉴스레터", index: 1)
                }
                .padding(.top, 16)
            } else {
                HStack(spacing: 0) {
                    tabButton(title: "추천 뉴스레터", index: 0)
                    tabButton(title: "모든 뉴스레터", index: 1)
                }
                .padding(.top, 16)
            }

            GeometryReader { geometry in
                let width = geometry.size.width / 2
                Rectangle()
                    .fill(Color.captionStrong)
                    .frame(width: width, height: 2)
                    .offset(x: viewModel.selectedTab == 0 ? 0 : width)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.selectedTab)
            }
            .frame(height: 2)
        }
    }
    
    private var noProfileSection: some View {
        VStack {
            Spacer()

            VStack(spacing: 0) {
                Image(asset: DesignSystemAsset.nologin)
                    .resizable()
                    .frame(width: 280, height: 280)
                    .padding(.bottom, 24)

                Text("프로필을 등록해 주세요.")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundStyle(Color.captionHeavy)
                    .padding(.bottom, 4)

                Text("\(nickname)님만을 위한 뉴스레터를 찾아드릴게요!")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionBody)
                    .padding(.bottom, 24)

                Button(action: {
                    router.push(.editProfile)
                }) {
                    Text("프로필 등록하기")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.primaryNormal)
                        .cornerRadius(4)
                }
                .padding(.horizontal, 24)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgSystem)
    }
    
    private var guestSection: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(asset: DesignSystemAsset.nologin)
                .resizable()
                .frame(width: 280, height: 280)
                .padding(.top, 20)
                .padding(.bottom, 24)
            Text("회원이 되면 뉴스레터를\n간편하게 모아볼 수 있어요!")
                .font(.hanSansNeo(16, .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.captionHeavy)
                .padding(.bottom, 24)
            
            Button(action: {
                router.push(.signup)
            }) {
                Text("회원가입")
                    .font(.hanSansNeo(14, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 24)
            }
            HStack {
                Text("이미 계정이 있나요?")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionBody)
                Text("로그인")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.primaryNormal)
                    .underline()
                    .onTapGesture {
                        router.push(.login)
                    }
            }
            Spacer()
        }
        .background(Color.bgSystem)
    }

    private var recommendationSection: some View {
        VStack(alignment: .leading) {
            Text("\(nickname)님을 위한\n맞춤형 뉴스레터가 도착했어요.")
                .font(.hanSansNeo(20, .bold))
                .padding(.top, 20)
                .padding(.horizontal, 24)

            PagingScrollView(newsletters: viewModel.fixedMyRecommendation, currentPage: $currentPage)

            HStack(spacing: 0) {
                Text("이런 뉴스레터는 어때요?")
                    .font(.hanSansNeo(16, .bold))
                Spacer()
                Button(action: {
                    recommendationSpinAngle += 360
                    Task {
                        await viewModel.fetchRecommendation(forceRefresh: true)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(asset: DesignSystemAsset.lineReload)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .font(.hanSansNeo(14, .bold))
                            .foregroundStyle(Color.primaryNormal)
                            .rotationEffect(.degrees(recommendationSpinAngle))
                            .animation(.linear(duration: 0.8), value: recommendationSpinAngle)
                        Text("새로고침")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color.primaryNormal)
                    }
                }
                .disabled(viewModel.isRefreshingRecommendation)
            }
            .padding(.top, 20)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            VStack(spacing: 12) {
                ForEach(viewModel.fixedUnionRecommendation, id: \.id) { newsletter in
                    NewsletterRow(
                        newsletter: newsletter,
                        prioritizedInterests: viewModel.prioritizeInterestsForNewsletter(newsletter)
                    )
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        router.push(.brandDetail(id: "\(newsletter.id)"))
                    }
                }
            }
            .padding(.bottom, 80)
        }
    }
    private var newsletterFilterSection: some View {
        HStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    // 정렬 버튼
                    Button(action: {
                        viewModel.isShowSortSheet.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Text(viewModel.orderOpt ?? "인기순")
                                .font(.hanSansNeo(14, .medium))
                                .foregroundStyle(Color.captionStrong)
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.captionStrong)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.lineNeutral, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    Rectangle()
                        .frame(width: 1, height: 20)
                        .foregroundColor(Color.lineNeutral)

                    // 산업 필터
                    Button(action: {
                        viewModel.isShowFilterSheet.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Text(industryText)
                                .font(.hanSansNeo(14, .medium))
                                .foregroundStyle(viewModel.industry != nil ? Color.primaryNormal : Color.captionAssistive)
                            Image(asset: DesignSystemAsset.lineDown)
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(viewModel.industry != nil ? Color.primaryNormal : Color.captionAssistive)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(viewModel.industry != nil ? Color.primaryNormal : Color.lineNeutral, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    // 요일 필터
                    Button(action: {
                        viewModel.isShowFilterSheet.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Text(dayText)
                                .font(.hanSansNeo(14, .medium))
                                .foregroundStyle(viewModel.day != nil ? Color.primaryNormal : Color.captionAssistive)
                            Image(asset: DesignSystemAsset.lineDown)
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(viewModel.day != nil ? Color.primaryNormal : Color.captionAssistive)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(viewModel.day != nil ? Color.primaryNormal : Color.lineNeutral, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(maxWidth: .infinity)

            // 리프레시 버튼 고정
            Button(action: {
                filterSpinAngle += 360
                Task {
                    viewModel.day = nil
                    viewModel.industry = nil
                    viewModel.orderOpt = "인기순"
                    viewModel.shouldScrollToTop = true
                    if isGuest {
                        await viewModel.fetchGuestAllNewsletters()
                    } else {
                        await viewModel.fetchAllNewsletters()
                    }
                }
            }) {
                Image(asset: DesignSystemAsset.lineReload)
                    .renderingMode(.template)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.primaryNormal)
                    .rotationEffect(.degrees(filterSpinAngle))
                    .animation(.linear(duration: 0.8), value: filterSpinAngle)
            }
        }
        .sheet(isPresented: $viewModel.isShowSortSheet) {
            SortBottomSheet(orderOpt: $viewModel.orderOpt) {
                viewModel.shouldScrollToTop = true
                if isGuest {
                    await viewModel.fetchGuestAllNewsletters()
                } else {
                    await viewModel.fetchAllNewsletters()
                }
            }
            .background(Color.white)
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.isShowFilterSheet) {
            FilterBottomSheet(industry: $viewModel.industry, day: $viewModel.day) {
                viewModel.shouldScrollToTop = true
                if isGuest {
                    await viewModel.fetchGuestAllNewsletters()
                } else {
                    await viewModel.fetchAllNewsletters()
                }
            }
        }
    }

    // MARK: - 모든 뉴스레터
    private var allNewsletterSection: some View {
        VStack(spacing: 0) {
            // 고정된 필터 섹션
            VStack(spacing: 0) {
                newsletterFilterSection
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
            }
            .background(Color.white)
            .zIndex(1)
            
            // 스크롤 가능한 뉴스레터 리스트
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // 스크롤 대상이 될 상단 요소
                        Color.clear
                            .frame(height: 1)
                            .id("top")
                        
                        ForEach(viewModel.allNewsletters) { brand in
                            NewsletterDetailRow(brand: brand)
                                .padding(.horizontal, 20)
                                .onTapGesture {
                                    router.push(.brandDetail(id: "\(brand.id)"))
                                }
                        }
                    }
                    .padding(.bottom, 80)
                }
                .onChange(of: viewModel.orderOpt) {
                    // 필터 변경 시 자동 호출 제거 - 적용하기 버튼에서만 호출
                }
                .onChange(of: viewModel.industry) {
                    // 필터 변경 시 자동 호출 제거 - 적용하기 버튼에서만 호출
                }
                .onChange(of: viewModel.day) {
                    // 필터 변경 시 자동 호출 제거 - 적용하기 버튼에서만 호출
                }
                .onChange(of: viewModel.shouldScrollToTop) { _, shouldScroll in
                    if shouldScroll {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo("top", anchor: .top)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                viewModel.shouldScrollToTop = false
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - 탭 버튼 뷰
    @ViewBuilder
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            viewModel.selectedTab = index
        }) {
            Text(title)
                .font(.hanSansNeo(14, .bold))
                .foregroundColor(viewModel.selectedTab == index ? Color.captionStrong : Color.captionAlternative)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }
    
    private var industryText: String {
        guard let selected = viewModel.industry else { return "산업" }
        
        if selected.count == 1 {
            let industryName = SelectableItemStore.shared.name(for: selected.first!, in: .industry)
            return industryName.isEmpty ? "산업" : industryName
        } else {
            return "산업 \(selected.count)"
        }
    }

    private var dayText: String {
        guard let selected = viewModel.day else { return "발행요일" }
        
        let labels = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일", "기타"]
        
        if selected.count == 1 {
            let index = selected.first! - 1
            return index >= 0 && index < labels.count ? labels[index] : "발행요일"
        } else {
            return "발행요일 \(selected.count)"
        }
    }

    // 배열 안전 서브스크립트
}
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct PagingScrollView: View {
    private let items: [NewsletterDetail]
    @Binding var currentPage: Int
    
    @EnvironmentObject private var router: AppRouter
    @State private var scrollID: Int?
    @State private var dynamicItems: [NewsletterDetail] = []
    
    private let itemWidth: CGFloat = 320
    private let itemHeight: CGFloat = 350
    private let itemSpacing: CGFloat = 12
    
    private let leadingMargin: CGFloat = 24
    
    init(newsletters: [NewsletterDetail], currentPage: Binding<Int>) {
        self._currentPage = currentPage
        self.items = newsletters
    }
    
    private func checkAndExpandItems() {
        guard !items.isEmpty else { return }
        // 끝에 가까워지면 더 추가
        let threshold = dynamicItems.count - 10
        if currentPage >= threshold {
            DispatchQueue.main.async {
                dynamicItems.append(contentsOf: items)
            }
        }
    }
    
    private func resetCarouselItems() {
        guard !items.isEmpty else {
            dynamicItems = []
            scrollID = nil
            currentPage = 0
            return
        }
        // 기본 데이터를 세트로 복제해 무한 스크롤 구현
        dynamicItems = items + items + items
        scrollID = 0
        currentPage = 0
    }
    
    var body: some View {
        GeometryReader { geo in
            let trailingSpace = max(0, geo.size.width - itemWidth - leadingMargin + 12)
            
            VStack(spacing: 12) {
                // MARK: - 캐러셀
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: itemSpacing) {
                        ForEach(dynamicItems.indices, id: \.self) { index in
                            let newsletter = dynamicItems[index]
                            RecommendedNewsLetterView(recommendation: newsletter)
                                .frame(width: itemWidth, height: itemHeight)
                                .id(index)
                                .onTapGesture {
                                    router.push(.brandDetail(id: "\(newsletter.id)"))
                                }
                        }
                        
                        Color.clear
                            .frame(width: trailingSpace)
                    }
                    .padding(.leading, leadingMargin)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollID)
                .onChange(of: scrollID) { _, newValue in
                    currentPage = newValue ?? 0
                    checkAndExpandItems()
                }
                .onAppear {
                    resetCarouselItems()
                    if scrollID == nil {
                        scrollID = 0
                    }
                }
                .onChange(of: items.map(\.id)) { _, _ in
                    resetCarouselItems()
                }
                .frame(height: itemHeight)
                
                // MARK: - 페이지 인디케이터
                let indicatorCount = min(5, items.count)
                if indicatorCount > 0 {
                    HStack(spacing: 6) {
                        ForEach(0..<indicatorCount, id: \.self) { idx in
                            Circle()
                                .fill(idx == (currentPage % indicatorCount)
                                      ? Color.primaryNormal
                                      : Color.primaryBgMuted)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .frame(width: geo.size.width)
        }
        .frame(height: itemHeight + 60)
    }
}
