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

    public init(viewModel: ExploreViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    let userName = "닉네임"

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
            Text("\(userName)님을 위한\n맞춤형 뉴스레터가 도착했어요.")
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
            Button(action: {
                //showSortSheet = true
            }) {
                HStack {
                    Text("인기순")
                        .font(.hanSansNeo(14,.medium))
                    Image(systemName: "arrow.up.arrow.down")
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
            
            Button(action: {
                viewModel.isShowFilterSheet.toggle()
            }) {
                HStack {
                    Text("산업")
                        .font(.hanSansNeo(14,.medium))
                    Image(systemName: "chevron.down")
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
            
            Button(action: {
                //showWeekdaySheet = true
            }) {
                HStack {
                    Text("발행 요일")
                        .font(.hanSansNeo(14,.medium))
                    Image(systemName: "chevron.down")
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
            
            Spacer()
            
            Button(action: {
                //showResetSheet = true
            }) {
                Image(asset: DesignSystemAsset.refresh)
                    .foregroundColor(.blue)
            }
        }
//        .sheet(isPresented: $showSortSheet) {
//            Text("정렬 모달")
//                .presentationDetents([.medium])
//        }
        .sheet(isPresented: $viewModel.isShowFilterSheet) {
            FilterBottomSheet  { _, _ in
            }
            .presentationDragIndicator(.hidden)
        }
                
//        .sheet(isPresented: $showWeekdaySheet) {
//            Text("요일 모달")
//                .presentationDetents([.medium])
//        }
//        .sheet(isPresented: $showResetSheet) {
//            Text("초기화 모달")
//                .presentationDetents([.medium])
//        }
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
