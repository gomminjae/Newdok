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
import Lottie 
import Combine

public struct ExploreView: View {
    
    @StateObject private var viewModel: ExploreViewModel
    @State private var currentPage: Int = 0
    @State private var isLoaded: Bool = false
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var exploreIntent: ExploreIntent
    
    
    @AppStorage("nickname") public var nickname = ""
    @AppStorage("isGuest") private var isGuest: Bool = false

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
                            ScrollView(showsIndicators: false) {
                                allNewsletterSection
                            }
                        } else {
                            guestSection
                        }
                    }
                } else {
                    Group {
                        if viewModel.selectedTab == 0 {
                            if !isLoaded {
                                EmptyView() //후에 로딩뷰
                            } else if !viewModel.hasUserProfile {
                                noProfileSection
                            } else {
                                ScrollView(showsIndicators: false) {
                                    recommendationSection
                                }
                                .background(Color(hex: "#F5F5F7"))
                            }
                        } else {
                            ScrollView(showsIndicators: false) {
                                allNewsletterSection
                            }
                            .background(Color(hex: "#F5F5F7"))
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
            }
            .onReceive(Just(exploreIntent.trigger)) { _ in
                var didUpdate = false
                if let day = exploreIntent.day, viewModel.day != [day] {
                    viewModel.day = [day]
                    exploreIntent.day = nil
                    didUpdate = true
                }
                if let tab = exploreIntent.selectedTab, viewModel.selectedTab != tab {
                    viewModel.selectedTab = tab
                    exploreIntent.selectedTab = nil
                    didUpdate = true
                }
                // trigger는 항상 새로 할당되므로 별도 리셋 불필요
            }
            .onAppear {
                Task {
                    if isGuest {
                        await viewModel.fetchGuestAllNewsletters()
                    } else {
                        await viewModel.fetchRecommendation()
                        await viewModel.fetchAllNewsletters()
                    }
                    isLoaded = true
                    
                }
            }
        }
    }

    // MARK: - 헤더
    private var headerView: some View {
        HStack {
            Text("둘러보기")
                .font(.hanSansNeo(16, .bold))
                .foregroundStyle(Color(hex: "161616"))
                .padding(.vertical, 17)
                .padding(.leading, 20)
            Spacer()
            Button {
                print("검색 버튼 탭")
                router.push(.search)
            } label: {
                Image(asset: DesignSystemAsset.lineSearch)
                    .padding(.vertical, 14)
                    .padding(.trailing, 12)
            }
            Button {
                print("알람 버튼 탭")
            } label: {
                Image(asset: DesignSystemAsset.lineBell)
                    .padding(.vertical, 14)
                    .padding(.trailing, 20)
            }
        }
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
                    .fill(Color(hex: "#363636"))
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
                    .foregroundStyle(Color(hex: "#161616"))
                    .padding(.bottom, 4)

                Text("\(nickname)님만을 위한 뉴스레터를 찾아드릴게요!")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "#555555"))
                    .padding(.bottom, 24)

                Button(action: {
                    router.push(.editProfile)
                }) {
                    Text("프로필 등록하기")
                        .font(.hanSansNeo(14,.bold))
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
        .background(Color(hex: "#F5F5F7"))
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
                .foregroundStyle(Color(hex: "161616"))
                .padding(.bottom, 24)
            
            Button(action: {
                router.push(.signup)
            }) {
                Text("회원가입")
                    .font(.hanSansNeo(14,.bold))
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
                    .font(.hanSansNeo(14,.medium))
                    .foregroundStyle(Color(hex: "555555"))
                Text("로그인")
                    .font(.hanSansNeo(14,.medium))
                    .foregroundStyle(Color.primaryNormal)
                    .underline()
                    .onTapGesture {
                        router.push(.login)
                    }
            }
            Spacer()
            
            
        }
        .background(Color(hex: "#F5F5F7"))
    }

    
    
    private var recommendationSection: some View {
        VStack(alignment: .leading) {
            Text("\(nickname)님을 위한\n맞춤형 뉴스레터가 도착했어요.")
                .font(.hanSansNeo(20, .bold))
                .padding(.top, 20)
                .padding(.horizontal, 24)

            PagingScrollView(newsletters: viewModel.fixedMyRecommendation, currentPage: $currentPage)
                .padding(.leading,24)



            HStack(spacing: 0) {
                Text("이런 뉴스레터는 어때요?")
                    .font(.hanSansNeo(16, .bold))
                Spacer()
                Button(action: {
                    Task {
                        await viewModel.fetchRecommendation()
                    }
                }) {
                    Image(asset: DesignSystemAsset.lineReload)
                       
                        .renderingMode(.template)
                        .resizable()
                        .frame(width:20, height: 20)
                        .font(.hanSansNeo(14,.bold))
                        .foregroundStyle(Color.primaryNormal)
                    Text("새로고침")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color.primaryNormal)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            VStack(spacing: 12) {
                ForEach(viewModel.fixedUnionRecommendation, id: \.id) { newsletter in
                    NewsletterRow(newsletter: newsletter)
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
                                .font(.hanSansNeo(14,.medium))
                                .foregroundStyle(Color(hex: "#363636"))
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(hex: "#363636"))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3))
                        )
                    }
                    Divider()
                        .frame(height: 20)

                    // 산업 필터
                    Button(action: {
                        viewModel.isShowFilterSheet.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Text(industryText)
                                .font(.hanSansNeo(14,.medium))
                                .foregroundStyle(viewModel.industry != nil ? Color.primaryNormal : Color(hex: "969696"))
                            Image(asset: DesignSystemAsset.lineDown)
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(viewModel.industry != nil ? Color.primaryNormal : Color(hex: "969696"))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(viewModel.industry != nil ? Color.primaryNormal : Color(hex :"EBEBEB"))
                        )
                    }

                    // 요일 필터
                    Button(action: {
                        viewModel.isShowFilterSheet.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Text(dayText)
                                .font(.hanSansNeo(14,.medium))
                                .foregroundStyle(viewModel.day != nil ? Color.primaryNormal : Color(hex: "969696"))
                            Image(asset: DesignSystemAsset.lineDown)
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(viewModel.day != nil ? Color.primaryNormal : Color(hex: "969696"))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(viewModel.day != nil ? Color.primaryNormal : Color.gray.opacity(0.3))
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity)

            // 리프레시 버튼 고정
            Button(action: {
                Task {
                    viewModel.day = nil
                    viewModel.industry = nil
                    viewModel.orderOpt = "인기순"
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
            }
        }
        .sheet(isPresented: $viewModel.isShowSortSheet) {
            SortBottomSheet(orderOpt: $viewModel.orderOpt) {
                if isGuest {
                    await viewModel.fetchGuestAllNewsletters()
                } else {
                    await viewModel.fetchAllNewsletters()
                }
            }
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.isShowFilterSheet) {
            FilterBottomSheet(industry: $viewModel.industry, day: $viewModel.day) {
                if isGuest {
                    await viewModel.fetchGuestAllNewsletters()
                } else {
                    await viewModel.fetchAllNewsletters()
                }
            }
            .presentationDragIndicator(.hidden)
        }
    }




    // MARK: - 모든 뉴스레터
    private var allNewsletterSection: some View {
        VStack(spacing: 0) {
            newsletterFilterSection
                .padding(.horizontal,20)
                .padding(.top, 20)
                .padding(.bottom, 16)
            LazyVStack(spacing: 12) {
                
                ForEach(viewModel.allNewsletters) { brand in
                    NewsletterDetailRow(brand: brand)
                        .padding(.horizontal, 20)
                        .onTapGesture {
                            print("tapped")
                            router.push(.brandDetail(id: "\(brand.id)"))
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
                .foregroundColor(viewModel.selectedTab == index ? Color(hex: "#363636") : Color(hex: "#767676"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }
    
    private var industryText: String {
        guard let selected = viewModel.industry else { return "산업" }
        let labels = ["IT·게임·통신", "F&B", "패션", "유통·무역", "의료", "자영업", "생활·서비스", "건설", "광고", "교육", "금융·부동산", "미디어", "문화·예술·엔터", "생산·제조", "기타"]
        return selected.count == 1 ? labels[selected.first! - 1] : "산업 \(selected.count)"
    }

    private var dayText: String {
        guard let selected = viewModel.day else { return "발행요일" }
        let labels = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일", "기타"]
        return selected.count == 1 ? labels[selected.first! - 1] : "발행요일 \(selected.count)"
    }

    // 배열 안전 서브스크립트
}
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}




import SwiftUI

struct PagingScrollView: View {
    
    private let items: [NewsletterDetail]
    @Binding var currentPage: Int
    
    @EnvironmentObject private var router: AppRouter
    @State private var scrollID: Int?
    
  
    private let itemWidth: CGFloat = 320
    private let itemHeight: CGFloat = 350
    private let itemSpacing: CGFloat = 12
    
    private let leadingMargin: CGFloat = 24
    
   
    init(newsletters: [NewsletterDetail], currentPage: Binding<Int>) {
        self._currentPage = currentPage
        self.items = newsletters
    }
    
    var body: some View {
        GeometryReader { geo in
            
        
            let trailingSpace = max(0, geo.size.width - itemWidth - leadingMargin + 12)
            
            VStack(spacing: 12) {
                // MARK: - 캐러셀
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: itemSpacing) {
                        ForEach(items.indices, id: \.self) { index in
                            let newsletter = items[index]
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
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollID)
                .onChange(of: scrollID) { newValue in
                    currentPage = newValue ?? 0
                }
                .frame(height: itemHeight)
                
                // MARK: - 페이지 인디케이터
                HStack(spacing: 6) {
                    ForEach(items.indices, id: \.self) { idx in
                        Circle()
                            .fill(idx == currentPage
                                  ? Color.primaryNormal
                                  : Color(hex: "#CCDFFF"))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 20)
            }
            .frame(width: geo.size.width)
        }
        .frame(height: itemHeight + 60)
    }
}


