//
//  HomeViewResult.swift
//  Home
//
//  Created by AI Assistant on 1/14/25.
//

import SwiftUI
import DesignSystem
import Shared
import Domain
import PopupView
import Lottie

public struct HomeViewResult: View {
    @StateObject private var viewModel: HomeViewModelResult
    @State private var showCalendar = false
    @State private var calendarDisplayedMonth = Date()
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection
    @EnvironmentObject private var exploreIntent: ExploreIntent
    @AppStorage("isGuest") private var isGuest: Bool = false
    
    public init(viewModel: HomeViewModelResult) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            Color(hex: "F5F5F7").ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                ScrollView {
                    dateBarView
                    contentView
                }
                .background(Color(hex: "#F5F5F7"))
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 8)
            .padding(.top, 8)
        }
        .navigationBarHidden(true)
        .onAppear {
            if !isGuest {
                Task { await viewModel.loadToday() }
            }
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") {
                // 에러 메시지는 자동으로 초기화됨
            }
            Button("다시 시도") {
                Task { await viewModel.loadToday() }
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var headerView: some View {
        HStack {
            Text("홈")
                .font(.hanSansNeo(20, .bold))
                .foregroundStyle(Color(hex: "161616"))
            
            Spacer()
            
            // 로딩 인디케이터
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryNormal))
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var dateBarView: some View {
        HStack {
            HStack(spacing: 8) {
                Image(asset: DesignSystemAsset.calendar)
                Text(viewModel.formattedDate)
                    .font(.hanSansNeo(16, .medium))
                    .foregroundStyle(Color(hex: "161616"))
            }
            .onTapGesture {
                showCalendar.toggle()
            }
            
            Spacer()
            
            Button {
                Task { await viewModel.loadToday() }
            } label: {
                Image(asset: DesignSystemAsset.refresh)
                    .foregroundColor(.primaryNormal)
            }
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .sheet(isPresented: $showCalendar) {
            CalendarView(
                displayedMonth: $calendarDisplayedMonth,
                selectedDate: $viewModel.selectedDate,
                availableDates: viewModel.articlesByMonthDates
            ) { selectedDate in
                viewModel.selectedDate = selectedDate
                Task {
                    await viewModel.loadArticles(for: selectedDate)
                    viewModel.filterArticles(by: selectedDate)
                }
                showCalendar = false
            }
            .presentationDetents([.fraction(0.6)])
        }
    }

    private var contentView: some View {
        switch viewModel.homeState {
        case .none:
            if viewModel.isLoading {
                LoadingView()
                    .frame(height: 300)
            } else {
                EmptyView()
            }
        case .guest:
            NoDataView(
                type: .guest,
                buttonAction: {
                    router.push(.login)
                }
            )
        case .noSubscriptions:
            NoDataView(
                type: .noSubscriptions,
                buttonAction: {
                    exploreIntent.selectedTab = 0
                    exploreIntent.trigger = UUID()
                    router.resetTo(.tabbar(selectedTab: .explore))
                },
                refreshAction: {
                    Task { await viewModel.loadToday() }
                }
            )
        case .noArticles:
            NoDataView(
                type: .noArticles,
                buttonAction: {
                    router.resetTo(.tabbar(selectedTab: .explore))
                },
                refreshAction: {
                    Task { await viewModel.loadToday() }
                }
            )
        case .articles:
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredArticles, id: \.id) { article in
                    Button {
                        router.push(.articleDetail(id: String(article.id)))
                    } label: {
                        ArticleRow(
                            article: article,
                            onBookmarkTap: { articleId in
                                // 북마크 토글 로직은 ArticleDetail에서 처리
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Supporting Views
private struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryNormal))
                .scaleEffect(1.2)
            
            Text("오늘의 아티클을 불러오고 있습니다...")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "565656"))
        }
    }
}

private struct CalendarView: View {
    @Binding var displayedMonth: Date
    @Binding var selectedDate: Date
    let availableDates: Set<Date>
    let onDateSelected: (Date) -> Void
    
    var body: some View {
        VStack {
            Text("날짜 선택")
                .font(.hanSansNeo(18, .bold))
                .padding()
            
            // 간단한 달력 UI (실제 구현 필요)
            Text("달력 구현 예정")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "565656"))
                .frame(height: 200)
            
            Spacer()
        }
    }
}

private struct ArticleRow: View {
    let article: Article
    let onBookmarkTap: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(article.title)
                    .font(.hanSansNeo(16, .medium))
                    .foregroundStyle(Color(hex: "161616"))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button {
                    onBookmarkTap(article.id)
                } label: {
                    Image(systemName: article.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(article.isBookmarked ? .primaryNormal : Color(hex: "565656"))
                }
            }
            
            Text(article.content)
                .font(.hanSansNeo(14, .regular))
                .foregroundStyle(Color(hex: "565656"))
                .lineLimit(2)
            
            HStack {
                Text(article.brandName)
                    .font(.hanSansNeo(12, .medium))
                    .foregroundStyle(Color(hex: "999999"))
                
                Spacer()
                
                Text(article.date)
                    .font(.hanSansNeo(12, .regular))
                    .foregroundStyle(Color(hex: "999999"))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

private struct NoDataView: View {
    enum DataType {
        case guest
        case noSubscriptions
        case noArticles
    }
    
    let type: DataType
    let buttonAction: () -> Void
    let refreshAction: (() -> Void)?
    
    init(type: DataType, buttonAction: @escaping () -> Void, refreshAction: (() -> Void)? = nil) {
        self.type = type
        self.buttonAction = buttonAction
        self.refreshAction = refreshAction
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "CCCCCC"))
            
            Text(title)
                .font(.hanSansNeo(16, .medium))
                .foregroundStyle(Color(hex: "161616"))
            
            Text(subtitle)
                .font(.hanSansNeo(14, .regular))
                .foregroundStyle(Color(hex: "565656"))
                .multilineTextAlignment(.center)
            
            Button(buttonTitle) {
                buttonAction()
            }
            .font(.hanSansNeo(14, .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.primaryNormal)
            .cornerRadius(6)
            
            if let refreshAction = refreshAction {
                Button("새로고침") {
                    refreshAction()
                }
                .font(.hanSansNeo(12, .medium))
                .foregroundColor(Color(hex: "565656"))
            }
        }
        .frame(height: 300)
    }
    
    private var iconName: String {
        switch type {
        case .guest:
            return "person.circle"
        case .noSubscriptions:
            return "envelope"
        case .noArticles:
            return "doc.text"
        }
    }
    
    private var title: String {
        switch type {
        case .guest:
            return "로그인이 필요합니다"
        case .noSubscriptions:
            return "구독중인 뉴스레터가 없습니다"
        case .noArticles:
            return "오늘 받은 아티클이 없습니다"
        }
    }
    
    private var subtitle: String {
        switch type {
        case .guest:
            return "로그인하고 맞춤 뉴스레터를\n받아보세요"
        case .noSubscriptions:
            return "관심있는 뉴스레터를 구독하고\n매일 새로운 소식을 받아보세요"
        case .noArticles:
            return "구독중인 뉴스레터에서\n새로운 아티클을 확인해보세요"
        }
    }
    
    private var buttonTitle: String {
        switch type {
        case .guest:
            return "로그인"
        case .noSubscriptions:
            return "뉴스레터 둘러보기"
        case .noArticles:
            return "뉴스레터 둘러보기"
        }
    }
} 