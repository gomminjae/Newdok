//
//  HomeView.swift
//  Newdok
//
//  Created by 권민재 on 2/18/25.
//

import SwiftUI
import DesignSystem
import Shared
import Domain
import PopupView




public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showCalendar = false
    @State private var isRefreshing = false
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection
    @EnvironmentObject private var exploreIntent: ExploreIntent
    @AppStorage("isGuest") private var isGuest: Bool = false

    public init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            // 1) 메인 배경+컨텐츠
            Color(hex: "F5F5F7").ignoresSafeArea().zIndex(0)
            
            VStack(spacing: 0) {
                headerView
                
                PullToRefreshView(
                    cooldownInterval: 2.0, // 2초 제한으로 조절
                    content: {
                        VStack(spacing: 0) {
                            dateBarView
                            contentView
                        }
                    },
                    animationView: {
                        AnyView(LoadingView())
                    },
                    onRefresh: {
                        await viewModel.loadToday()
                    }
                )
                
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            .zIndex(0)
        }
        .popup(isPresented: $showCalendar) {
                CalendarPopupView(
                    isPresented: $showCalendar,
                    selectedDate: Binding(
                        get: { viewModel.calendarState.selectedDate },
                        set: { viewModel.calendarState.selectedDate = $0 }
                    ),
                    displayedMonthDate: Binding(
                        get: { viewModel.calendarState.displayedMonth },
                        set: { viewModel.calendarState.displayedMonth = $0 }
                    ),
                    dataDays: Binding(
                        get: { viewModel.dataDays },
                        set: { viewModel.dataDays = $0 }
                    ),
                    onDateSelected: { date in
                        viewModel.selectDateWithMonthGuarantee(date)
                    },
                    onMonthChanged: { month in
                        // 캐시된 점 데이터를 반환 (홈 화면에는 영향 없음)
                        return viewModel.getDataDaysForMonth(month) ?? []
                    }
                )
                .padding(.horizontal, 24)
                 
              
            } customize: {
                $0
                  .type(.default)
                  .position(.center)
                  .animation(.easeInOut)
                  .closeOnTap(false)
                  .closeOnTapOutside(false)
                  .backgroundColor(Color(hex: "#25242C").opacity(0.6))
                 
            }
            .navigationBarHidden(true)
            .onAppear {
                if !isGuest {
                    // 최초 1회만 로드. 상세에서 pop하여 다시 나타날 때는 상태를 유지
                    if !viewModel.isLoaded {
                        Task { await viewModel.loadToday() }
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .init("RefreshHome"))) { _ in
                if !isGuest {
                    Task { await viewModel.refreshCurrentData() }
                }
            }
            .onChange(of: isGuest) { _, newValue in
                viewModel.resetForAuthChange()
                if newValue == false {
                    Task { await viewModel.loadToday() }
                }
            }

        }

    // MARK: — 헤더
    private var headerView: some View {
        HStack {
            Image(asset: DesignSystemAsset.logo)
                .resizable()
                .frame(width: 126, height: 24)
                .padding(.vertical, 16)
                .padding(.leading, 20)

            Spacer()

            HStack(spacing: 16) {
                Button(action: { router.push(.search) }) {
                    Image(asset: DesignSystemAsset.lineSearch)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .padding(.vertical, 14)
                }
                Button(action: { print("알람") }) {
                    Image(asset: DesignSystemAsset.lineBell)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .padding(.vertical, 14)
                        .padding(.trailing, 20)
                }
            }
        }
        .background(Color(hex: "#F5F5F7"))
    }

    // MARK: — 날짜 바
    private var dateBarView: some View {
        HStack(spacing: 0) {
            Text(viewModel.formattedDate)
                .font(.hanSansNeo(16, .bold))
                .foregroundStyle(Color(hex: "#363636"))
                .padding(.leading, 24)

            Spacer()

            Button(action:
            {
                Task {
                    let calendar = Calendar.current
                    let monthDate = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.selectedDate)) ?? viewModel.selectedDate
                    // 먼저 헤더/캘린더의 월을 동기화
                    await MainActor.run { viewModel.calendarState.displayedMonth = monthDate }
                    // 캐시된 점을 즉시 적용
                    await MainActor.run { viewModel.applyDataDaysForMonth(monthDate) }
                    let vm = viewModel
                    await vm.loadCalendarData(for: monthDate)
                    await MainActor.run { showCalendar = true }
                }
            }) {
                Image(asset: DesignSystemAsset.lineCalendar)
                    .padding(.trailing, 24)
            }
        }
        .frame(height: 52)
        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 12)))
        .padding(.bottom, 16)
    }

    // MARK: — 본문 컨텐츠
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.homeState {
        case .none:
            EmptyView()
        case .guest:
            NoDataView(
                type: .requireSignUp,
                buttonAction: { router.push(.signup) },
                loginAction: { router.push(.login) },
                refreshAction: { Task { await viewModel.loadToday() } }
            )
        case .noSubscriptions:
            NoDataView(
                type: .noSubscriptions,
                buttonAction: {
                    exploreIntent.selectedTab = 0
                    exploreIntent.trigger = UUID()
                    router.resetTo(.tabbar(selectedTab: .explore))
                    tabSelection.selectedTab = .explore
                },
                refreshAction: { Task { await viewModel.loadToday() } }
            )
        case .noArticles:
            NoDataView(
                type: .noArticles,
                buttonAction: {
                    let weekday = Calendar.current.component(.weekday, from: viewModel.selectedDate)
                    let dayIndex = convertWeekdayToExploreIndex(weekday)
                    tabSelection.selectedTab = .explore
                    router.resetTo(.tabbar(selectedTab: .explore))
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        exploreIntent.day = dayIndex
                        exploreIntent.selectedTab = 1
                        exploreIntent.trigger = UUID()
                    }
                },
                refreshAction: { Task { await viewModel.loadToday() } },
                selectedDate: viewModel.selectedDate
            )
        case .articles:
            articlesSection
        }
    }

    // MARK: — 아티클 리스트
    private var articlesSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(viewModel.filteredArticles.count)개의 아티클이 도착했어요.")
                    .font(.hanSansNeo(18, .bold))
                    .padding(.top, 20)
                    .padding(.leading, 28)

                Spacer()

                Button(action: {
                    Task {
                        await viewModel.loadToday()
                    }
                }) {
                    HStack(spacing: 4) {
                        
                        Image(asset: DesignSystemAsset.lineReload)
                            .renderingMode(.template)
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color.primaryNormal)
                        Text("새로고침")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color.primaryNormal)
                    }
                    
                }
                .padding(.top, 23)
                .padding(.trailing, 24)
            }

            VStack(spacing: 8) {
                ForEach(viewModel.filteredArticles) { article in
                    ArticleRow(article: article)
                        .frame(height: 88)
                        .onTapGesture {
                            // 로컬에서 먼저 읽음 상태로 변경
                            viewModel.markArticleAsRead(articleId: article.articleId)
                            router.push(.articleDetail(id: "\(article.articleId)"))
                        }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 12)))
    }

    private func convertWeekdayToExploreIndex(_ weekday: Int) -> Int {
        switch weekday {
        case 1: return 7
        case 2: return 1
        case 3: return 2
        case 4: return 3
        case 5: return 4
        case 6: return 5
        case 7: return 6
        default: return 0
        }
    }
}

