//
//  ExploreView.swift
//  Newdok
//
//  Created by 권민재 on 2/23/25.
//
import SwiftUI
import DesignSystem
import Shared
import Domain

public struct ExploreView: View {
    @State private var selectedTab: Int = 0 // 0: 추천, 1: 전체
    @State private var currentPage: Int = 0

    @StateObject private var viewModel: ExploreViewModel
    @EnvironmentObject private var router: AppRouter
    
    
    @AppStorage("nickname") public var nickname = ""

    public init(viewModel: ExploreViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }


    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                tabSwitcher
                Divider()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        if selectedTab == 0 {
                            recommendationSection
                        } else {
                            allNewsletterSection
                        }
                    }
                    .background(Color(hex: "#F5F5F7"))
                }
                .padding(.bottom, 0)
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.white)
            .onAppear {
                Task {
                    await viewModel.fetchRecommendation()
                    await viewModel.fetchAllNewsletters()
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
            HStack(spacing: 0) {
                tabButton(title: "추천 뉴스레터", index: 0)
                tabButton(title: "모든 뉴스레터", index: 1)
            }
            .padding(.top, 16)

            GeometryReader { geometry in
                let width = geometry.size.width / 2
                Rectangle()
                    .fill(Color(hex: "#363636"))
                    .frame(width: width, height: 2)
                    .offset(x: selectedTab == 0 ? 0 : width)
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
            }
            .frame(height: 2)
        }
    }
    private var recommendationSection: some View {
        VStack(alignment: .leading) {
            Text("\(nickname)님을 위한\n맞춤형 뉴스레터가 도착했어요.")
                .font(.hanSansNeo(20, .bold))
                .padding(.top, 20)
                .padding(.horizontal, 24)

            PagingScrollView(newsletters: viewModel.myRecommendation, currentPage: $currentPage)
                .frame(height: 360)
                .padding(.leading,24)

            HStack(spacing: 6) {
                Spacer()
                ForEach(0..<viewModel.myRecommendation.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.primaryNormal : Color(hex: "#E0E0E0"))
                        .frame(width: 6, height: 6)
                }
                Spacer()
            }
            .padding(.vertical, 20)

            HStack {
                Text("이런 뉴스레터는 어때요?")
                    .font(.hanSansNeo(16, .bold))
                Spacer()
                Button(action: {
                    Task {
                        await viewModel.fetchRecommendation()
                    }
                }) {
                    Image(asset: DesignSystemAsset.refresh)
                        .font(.hanSansNeo(14,.bold))
                        .foregroundStyle(Color.primaryNormal)
                    Text("새로고침")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color.primaryNormal)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            VStack(spacing: 12) {
                ForEach(viewModel.unionRecommendation, id: \.id) { newsletter in
                    NewsletterRow(newsletter: newsletter)
                        .padding(.horizontal, 20)
                        
                }
            }
            .padding(.bottom, 80)
        }
    }
    private var newsletterFilterSection: some View {
        HStack(spacing: 12) {
            // 스크롤 가능한 필터 버튼들
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
                                .stroke(viewModel.industry != nil ? Color.primaryNormal : Color.gray.opacity(0.3))
                        )
                    }

                    // 요일 필터
                    Button(action: {
                        // showWeekdaySheet = true
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
                    await viewModel.fetchAllNewsletters()
                }
            }) {
                Image(asset: DesignSystemAsset.refresh)
                    .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $viewModel.isShowSortSheet) {
            SortBottomSheet(orderOpt: $viewModel.orderOpt) {
                await viewModel.fetchAllNewsletters()
            }
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.isShowFilterSheet) {
            FilterBottomSheet(industry: $viewModel.industry, day: $viewModel.day) {
                await viewModel.fetchAllNewsletters()
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
                    
                }
            }
        }
    }

    // MARK: - 탭 버튼 뷰
    @ViewBuilder
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            selectedTab = index
        }) {
            Text(title)
                .font(.hanSansNeo(14, .bold))
                .foregroundColor(selectedTab == index ? Color(hex: "#363636") : Color(hex: "#767676"))
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





struct PagingScrollView: View {
    let newsletters: [NewsletterDetail]
    @Binding var currentPage: Int

    @State private var dragOffset: CGFloat = .zero

    var body: some View {
        GeometryReader { proxy in
            let cardWidth: CGFloat = 320
            let spacing: CGFloat = 12
            let sidePadding: CGFloat = 24
            let pageWidth = cardWidth + spacing  // 🔥 반드시 spacing 포함해야 함

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(Array(newsletters.enumerated()), id: \.element.id) { index, newsletter in
                        RecommendedNewsLetterView(recommendation: newsletter)
                            .frame(width: cardWidth)
                    }
                }
                .padding(.horizontal, sidePadding)
                .offset(x: -CGFloat(currentPage) * pageWidth + dragOffset)
                .animation(.easeOut(duration: 0.25), value: currentPage)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold = pageWidth / 3
                            var newIndex = currentPage

                            if value.translation.width < -threshold {
                                newIndex = min(currentPage + 1, newsletters.count - 1)
                            } else if value.translation.width > threshold {
                                newIndex = max(currentPage - 1, 0)
                            }

                            withAnimation(.easeOut(duration: 0.25)) {
                                currentPage = newIndex
                                dragOffset = .zero
                            }
                        }
                )
            }
            .background(Color(hex: "F5F5F7"))
        }
    }
}
